\newpage

# 2 Continuous integration for monorepos

*Monorepos are highly-active code repositories. They can test the limits of conventional continuous integration. Semaphore is the only CI/CD around with easy out-of-the-box support for monorepos.*

## 2.1 Monorepo workflows should be easy to set up

Monorepos  [CI/CD workflow](https://semaphoreci.com/cicd) present their own set of challenges. By default, a CI/CD [pipeline](https://semaphoreci.com/blog/cicd-pipeline) will run from beginning to end on every commit. This is expected. After all, that’s the *continuous* in [continuous integration](https://semaphoreci.com/continuous-integration).

![Regular CI pipelines always run the whole pipeline](./figures/03-build1.png){ width=95% }

Running every job in the pipeline is perfectly fine on single-project repositories. But monorepos see a lot more activity. Even the smallest change will re-run the entire pipeline — **it is time-consuming and needlessly expensive**.  It just doesn’t make sense.

Semaphore [is the only CI/CD platform](https://semaphoreci.com/product/whats-new-2021) with native monorepo support. Its change-based execution feature lets you skip jobs when the relevant code has not been updated. This will let you ignore parts of the pipeline you’re not interested in re-running.

![Monorepo CI pipelines skip blocks related to unmodified code](./figures/03-build2.png){ width=95% }

## 2.2 How to set up monorepo workflows

In this section, we’ll set up a monorepo pipeline. We’ll use the [semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo) project as a starting point, but you can adapt these steps to any CI/CD workflow on Semaphore.

To follow this guide, you’ll need:

-   A GitHub account.
-   A [Semaphore](https://semaphoreci.com) account. Click on **Sign up with GitHub** to create a free trial account.

Go ahead and fork the [repository](https://github.com/semaphoreci-demos/semaphore-demo-monorepo) on GitHub. It contains three projects, each one in a separate folder:

-   `/service/billing`: written in Go, calculates user payments.
-   `/service/user`: a Ruby-based user registration service. Exposes a HTTP REST endpoint.
-   `/service/ui`: which is a web UI component. Written in Elixir.

All these parts are meant to work together, but each one may be maintained by a separate team and written in a different language.

Next, log in with your Semaphore account and click on **create new** on the upper left corner.

![Creating a new project](./figures/03-create-new.png){ width=95% }

Now, choose the repository you forked. Alternatively, if you prefer to jump directly to the final state, find the monorepo example and click on **fork & run**.

You can add people to the project at this point. When you’re done, click **Continue** and select “I want to configure this project from scratch.”

![Create a new pipeline](./figures/03-scratch.png){ width=95% }

We’ll start with the billing application. Find the Go starter workflow and click on customize:

![Select the Go starter workflow](./figures/03-go-starter.png){ width=95% }

You have to modify the job a bit before it works:

1.  The billing app uses Go version 1.14. So, change the first line to `sem-version go 1.14`.
2.  The code is located in the `services/billing` folder, add `cd services/billing` after `checkout`.

The full job should look like this:

``` bash
sem-version go 1.14
export GO111MODULE=on
export GOPATH=~/go
export PATH=/home/semaphore/go/bin:$PATH
checkout
cd services/billing
go get ./...
go test ./...
go build -v .
```

![Build job for billing app](./figures/03-go-build1.png){ width=95% }

Now click on **run the workflow**. Type “master” in Branch and click on **start**. Choosing the right branch matters because it affects how commits are calculated. We’ll talk about that in a bit.

![Run the workflow](./figures/03-run-master.png){ width=95% }

Semaphore should start building and testing the application.

![First run](./figures/03-first-run.png){ width=95% }

Let’s add a second application in the pipeline. Open editor by clicking on **Edit Workflow** on the upper right corner.

Add a new block. Then, add the commands to install and test a Ruby application:

``` bash
sem-version ruby 2.5
checkout
cd services/users
cache restore
bundle install
cache store
bundle exec ruby test.rb
```

And **uncheck** all the checkboxes under Dependencies.

![No dependencies in the User block](./figures/03-no-dep-user.png){ width=95% }

Add a third block to test the UI service. The following installs and tests the app. Remember to **uncheck** all block dependencies.

``` bash
checkout
cd services/ui
sem-version elixir 1.9
cache restore
mix local.hex --force
mix local.rebar --force
mix deps.get
mix deps.compile
cache store
mix test
```

![No dependencies in the UI block](./figures/03-no-dep-ui.png){ width=95% }

Now, what happens if we change a file inside the `/services/ui` folder?

![All blocks running](./figures/03-all-blocks1.png){ width=95% }

Yeah, despite only one of the projects has changed, all the blocks are running. This is… not optimal. For a big monorepo with hundreds of projects, **that’s a lot of wasted CPU cycles**. The good news is that this is a perfect fit for trying out change-based execution.

## 2.2 Change-based execution

The [change_in](https://docs.semaphoreci.com/reference/conditions-reference/#change_in) function calculates if recent commits have changed code in a given file or folder. We must call this function at block level. If it detects changes, then all the jobs in the block will be executed. Otherwise, the whole block is skipped. `change_in` allows us to tie a specific block to parts of the repository.

We can call the function from any block by opening the **skip/run conditions** section and enabling the option: “run this block when conditions are met.”

![Where to define run conditions](./figures/03-run-skip.png){ width=95% }

The basic usage of the function is:

``` json
change_in('/web/')
```

This will run the block if any files inside the `web` folder change. Absolute paths start with `/` and reference the root of the repository. Relative paths don’t start with a slash, they are relative to the pipeline file, which is located inside `/.semaphore`.

We can also target a specific file:

``` json
change_in('../package-lock.json')
```

Wildcards are supported too:

``` json
change_in('/**/package.json')
```

Also, you're not limited to monitoring one path, you may define lists of files or folders. This block, for instance, will run when the `/web/` folder **or** the `/manifests/kubernetes.yml` file changes (both simultaneously changing work too):

``` json
change_in(['/web/', '/manifests/kubernetes.yml'])
```

The function can take a second optional argument to further configue its behavior. For instance, if your repository default branch is `main` instead of `master` ([GitHub’s new default](https://github.com/github/renaming)), you’ll need to add `default_branch: 'main'`:

``` json
change_in('/web/', { default_branch: 'main' })
```

Semaphore will re-run all jobs when we update the pipeline. We can disable this behavior with `pipeline_file: 'ignore'`:

``` json
change_in('/web/', { pipeline_file: 'ignore' })
```

Another useful option is `exclude`, which lets us ignore files or folders. This option also supports wildcards. For example, to ignore all Markdown files:

``` json
change_in('/web/', { exclude: '/web/**/*.md' })
```

To see the rest of the options, check the [conditions YAML reference](https://docs.semaphoreci.com/reference/conditions-reference/).

## 2.3 Speeding up pipelines with change\_in

Let’s see how `change_in` can help us speed up the pipeline.

Open the workflow editor again. Pick one of the blocks and open the **skip/run conditions** section. Add some change criteria:

``` text
change_in('/services/billing')
```

Repeat the procedure for the rest of the blocks.

``` text
change_in('/services/ui')
```

And:

``` text
change_in('/services/users')
```

Next, run the pipeline again. The first thing you’ll notice is that there's a new initialization step. Here, Semaphore is calculating the differences to decide what blocks should run. You can check the log to see what is happening behind the scenes.

Once the workflow is ready, Semaphore will start running all jobs one more time (this happens because we didn’t set `pipeline_file: 'ignore' `). The interesting bit comes later, when we change a file in one of the applications, this is what we get:

![Running all blocks](./figures/03-skip-but-billing.png){ width=95% }

Can you guess which application I changed? Yes, that’s right: it was the billing app. As a result, thanks to `change_in`, the rest of the blocks have been skipped because neither did meet the change conditions.

If we make a change outside any of the monitored folders, then all the blocks are skipped and the pipeline completes in just a few seconds.

![Skipping all blocks](./figures/03-skip-all.png){ width=95% }

## 2.4 Calculating commit ranges

To understand what blocks will run each time, we must examine how `change_in` calculates the changed files in recent commits. The commit range varies depending on if you’re working on `main/master` or a topic branch.

For the main branch, Semaphore compares the changes in all the commits for the push, then skips the `change_in` blocks that do not have at least one match.

![Commit ranges per push on master/main](./figures/03-git-master.png){ width=95% }

Semaphore takes a broader criteria for branches. The commit range goes from the point of the first commit that branched off the mainline to the branch’s head. This explains why Semaphore may choose to re-run blocks even on commits that seemingly don’t match the change criteria.

![For branches, commit ranges go from the main branch to the branch’s head](./figures/03-git-branch.png){ width=95% }

Pull requests behave similarly. The commit range is defined from the first commit that branched off the branch targeted for merging to the head of the branch.

![For pull requests, commit ranges go from target branch to head of the branch](./figures/03-git-pr.png){ width=95% }

## 2.5 Change-based automatic promotions

We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

To create a new pipeline, open the workflow editor once more and click on **Add First Promotion**:

![Adding a promotion](./figures/03-add-promotion.png){ width=95% }

Check **Enable automatic promotion**. You should see an example snippet you can use as a starting point.

![Example change\_in condition](./figures/03-autopromotion-example.png){ width=95% }

You can combine `change_in` and `branch = 'master' AND result = 'passed'` to start the pipeline when all jobs pass on the default branch.

``` json
change_in('/services/billing/') and branch = 'master' AND result = 'passed'
```

![Auto promotion conditions](./figures/03-promotion-condition.png){ width=95% }

Once done, run the workflow to save the changes. From now on, when you make a change to the billing app, the new pipeline will start automatically if all tests pass on `master`.

![Pipeline auto promoted](./figures/03-promotion-done.png){ width=95% }

## 2.6 Tips for using `change_in` effectively

Scaling up large monorepos with `change_in` is easier if you follow these tips for organizing your code and pipelines:

-   Define a unified folder organization, so you can use clean change conditions.
-   Design your blocks around project folders.
-   When needed, add multiple files and folders to `change_in`. Use this to rebuild all the connected project components within a monorepo.
-   Keep branches small, and merge them frequently to cut build times.
-   Use `exclude` and wildcards to ignore files that are not relevant, such as documentation or READMEs.
-   Use `change_in` in auto-promotions to selectively trigger continuous delivery or deployment pipelines.

## 2.7 Monorepo workflows got a lot faster

We’ve learned how to best take advantage of Semaphore’s features to run CI/CD pipelines on monorepos. With the `change_in` function, you may design faster pipelines that don’t waste time or money re-building already-tested code.

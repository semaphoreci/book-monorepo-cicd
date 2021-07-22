## 3. Continuous integration for a microservice

In this section, we’ll set up a monorepo pipeline. We’ll use the [semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo) project as a starting point, but you can adapt these steps to any CI/CD workflow on Semaphore.

To follow this guide, you’ll need:

-   A GitHub account.
-   A [Semaphore](https://semaphoreci.com) account. Click on **Sign up with GitHub** to a free trial or open source account.

Go ahead and fork the repository:

_[https://github.com/semaphoreci-demos/semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo)_

The repo contains three projects, each one in a separate folder:

-   `/service/billing`: written in Go, calculates user payments.
-   `/service/user`: a Ruby-based user registration service. Exposes a HTTP REST endpoint.
-   `/service/ui`: which is a web UI component. Written in Elixir.

All these parts are meant to work together, but each one may be maintained by a separate team and written in a different language.

Next, log in with your Semaphore account and click on **create new** on the upper left corner.

![Creating a new project](./figures/04-create-new.png){ width=95% }

Now, choose the repository you forked. Alternatively, if you prefer to jump directly to the final state, find the monorepo example and click on **fork & run**.

You can add people to the project at this point. When you’re done, click **Continue** and select “I want to configure this project from scratch.”

![Create a new pipeline](./figures/04-scratch.png){ width=70% }

We’ll start with the billing application. Find the Go starter workflow and click on customize:

![Select the Go starter workflow](./figures/04-go-starter.png){ width=95% }

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

![Build job for billing app](./figures/04-go-build1.png){ width=95% }

Now click on **run the workflow**. Type “master” in Branch and click on **start**. Choosing the right branch matters because it affects how commits are calculated. We’ll talk about that in a bit.

![Run the workflow](./figures/04-run-master.png){ width=70% }

Semaphore should start building and testing the application.

![First run](./figures/04-first-run.png){ width=95% }

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

![No dependencies in the User block](./figures/04-no-dep-user.png){ width=95% }

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

![No dependencies in the UI block](./figures/04-no-dep-ui.png){ width=95% }

Now, what happens if we change a file inside the `/services/ui` folder?

![All blocks running](./figures/04-all-blocks1.png){ width=40% }

Yeah, despite only one of the projects has changed, all the blocks are running. This is… not optimal. For a big monorepo with hundreds of projects, that’s a lot of wasted hours, with added boredom and axiety for software developers. The good news is that this is a perfect fit for trying out change-based execution.

## 2.2 Change-based execution

The [change_in](https://docs.semaphoreci.com/reference/conditions-reference/#change_in) function calculates if recent commits have changed code in a given file or folder. We must call this function at block level. If it detects changes, then all the jobs in the block will be executed. Otherwise, the whole block is skipped. `change_in` allows us to tie a specific block to parts of the repository.

We can call the function from any block by opening the **skip/run conditions** section and enabling the option: “run this block when conditions are met.”

![Where to define run conditions](./figures/04-run-skip.png){ width=95% }

The basic usage of the function is:

``` text
change_in('/web/')
```

This will run the block if any files inside the `web` folder change. Absolute paths start with `/` and reference the root of the repository. Relative paths don’t start with a slash, they are relative to the pipeline file, which is located inside `/.semaphore`.

We can also target a specific file:

``` text
change_in('../package-lock.json')
```

Wildcards are supported too:

``` text
change_in('/**/package.json')
```

Also, you're not limited to monitoring one path, you may define lists of files or folders. This block, for instance, will run when the `/web/` folder **or** the `/manifests/kubernetes.yml` file changes (both simultaneously changing work too):

``` text
change_in(['/web/', '/manifests/kubernetes.yml'])
```

The function can take a second optional argument to further configue its behavior. For instance, if your repository default branch is `main` instead of `master` ([GitHub’s new default](https://github.com/github/renaming)), you’ll need to add `default_branch: 'main'`:

``` text
change_in('/web/', { default_branch: 'main' })
```

Semaphore will re-run all jobs when we update the pipeline. We can disable this behavior with `pipeline_file: 'ignore'`:

``` text
change_in('/web/', { pipeline_file: 'ignore' })
```

Another useful option is `exclude`, which lets us ignore files or folders. This option also supports wildcards. For example, to ignore all Markdown files:

``` text
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

![Running all blocks](./figures/04-skip-but-billing.png){ width=40% }

Can you guess which application I changed? Yes, that’s right: it was the billing app. As a result, thanks to `change_in`, the rest of the blocks have been skipped because neither did meet the change conditions.

If we make a change outside any of the monitored folders, then all the blocks are skipped and the pipeline completes in just a few seconds.

![Skipping all blocks](./figures/04-skip-all.png){ width=40% }

## 2.5 Change-based automatic promotions

We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

To create a new pipeline, open the workflow editor once more and click on **Add First Promotion**:

![Adding a promotion](./figures/04-add-promotion.png){ width=95% }

Check **Enable automatic promotion**. You should see an example snippet you can use as a starting point.

![Example change\_in condition](./figures/04-autopromotion-example.png){ width=90% }

You can combine `change_in` and `branch = 'master' AND result = 'passed'` to start the pipeline when all jobs pass on the default branch.

``` json
change_in('/services/billing/') and branch = 'master' AND result = 'passed'
```

![Auto promotion conditions](./figures/04-promotion-condition.png){ width=90% }

Once done, run the workflow to save the changes. From now on, when you make a change to the billing app, the new pipeline will start automatically if all tests pass on `master`.

![Pipeline auto promoted](./figures/04-promotion-done.png){ width=95% }


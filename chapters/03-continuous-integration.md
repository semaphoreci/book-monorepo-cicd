\newpage

# 2 Continuous Integration for Monorepos

Monorepos are highly-active code repositories. The default behavior of continuous integration systems, which is to build, test, and deploy everything all the time, is suboptimal in the context of a monorepo. In this chapter you will learn how to use Semaphore's out-of-the-box support for monorepo CI/CD workflows.

## 2.1 The Challenge of CI/CD with Monorepos

Properly implementing a CI/CD workflow with a monorepo presents its own set of challenges. By default, a CI/CD pipeline will run from beginning to end on every commit. This is expected. After all, that’s what the “continuous” in continuous integration stands for.

A classic CI pipeline will run every job in sequence every time a new commit is pushed into the repository.

![Regular CI pipelines always run the whole pipeline](./figures/03-build1-basic.png){ width=90% }

Running every job in the pipeline is perfectly fine on single-project repositories. But monorepos see a lot more activity. Even the smallest change will re-run the entire pipeline — **this is time-consuming and needlessly expensive**.

Semaphore is a CI/CD platform with native monorepo support. Its change-based, parallel execution feature lets you skip jobs when the relevant code has not changed. This will let you ignore parts of the pipeline you’re not interested in re-running.

![Monorepo CI pipelines skip blocks related to unmodified code](./figures/03-build2.png){ width=90% }

## 2.2 Hello World Monorepo with Semaphore

If you're new to Semaphore, spend 10 minutes reading the **getting started guide** to learn the basics of creating a pipeline. You'll find the guide here:

_<https://docs.semaphoreci.com/guided-tour/getting-started>_

Back? OK, let's walk through creating a monorepo pipeline.

To follow this guide, you’ll need:

-   A GitHub account.
-   A [Semaphore](https://semaphoreci.com) (_<https://semaphoreci.com>_) account. Click on *Sign up with GitHub* for a free trial or open source account.

Get started by creating a new repository on GitHub and cloning it to your machine. We'll call the repository "hello-semaphore".

Create a couple of folders in the repository in order to try out change-based detection. Let's call them `service1` and `service2`:

``` bash
$ mkdir service1 service2
$ touch service1/README.md service2/README.md
$ git add .
$ git commit -m "create dummy services"
$ git push
```

Next, log in with your Semaphore account and click on *Create New* in the upper left corner.

![Creating a new project](./figures/03-create-new.png){ width=85% }

After choosing the "hello-semaphore" repository, wait a few seconds for Semaphore to initialize the project.

![](./figures/03-choose-repo.png){ width=85% }

The next screen lets you add people to the project, which we don’t need to do for now. Go ahead and click *Continue to Workflow Setup* to proceed.

Finally, you’ll reach the template selection screen, select *Single job*, then click *Looks good,* followed by *start*.

![](./figures/03-single-job.png){ width=80% }

The initial workflow should start immediately.

![](./figures/03-edit-workflow.png){ width=80% }

Now click on *Edit Workflow* to edit the pipeline.

In this screen you can modify and create new blocks in the pipeline. Rename the block to "Build service1" and add the following command: `echo "building service1"`.

![](./figures/03-service1.png){ width=85% }

Click on *Add Block*, the new block is called "Build service2". Uncheck the Build service1 in dependencies. This causes both blocks to run in parallel. For the command, type `echo "building service2"`.

![](./figures/03-service2.png){ width=85% }

Click on *Run this Workflow*, change the branch to the default branch your repository uses (usually, it's called `main`) and click on *Start*.

![](./figures/03-run1.png){ width=70% }

Both blocks should run in parallel.

![](./figures/03-run1-done.png){ width=30% }

## 2.3 Change-Based Execution

Let's pause for a moment to learn about `change_in`. The [change_in](https://docs.semaphoreci.com/reference/conditions-reference/#change_in)[^changein] function calculates if recent commits have changed code in a given file or folder. This function must be called at the block level. If it detects changes, then all the jobs in the block will be executed. Otherwise, the whole block is skipped. The end result is that this function allows us to tie a specific block to parts of the repository.

[^changein]: Function change_in reference page - _<https://docs.semaphoreci.com/reference/conditions-reference/#change_in>_

The basic usage of the function is:

``` text
change_in('/web/')
```

This will run the block if any files inside the `web` folder have changed. Absolute paths start with `/` and reference the root of the repository. Relative paths don’t start with a slash, they are relative to the pipeline file, which is located inside `/.semaphore` by default.

We can also target a specific file:

``` text
change_in('../package-lock.json')
```

Wildcards are supported too:

``` text
change_in('/**/package.json')
```

Also, you're not limited to monitoring one path, you may define lists of files or folders. The following statement, for instance, will run when the `/web/` folder **or** the `/manifests/kubernetes.yml` file changes (both simultaneously changing work too):

``` text
change_in(['/web/', '/manifests/kubernetes.yml'])
```

The function can take a second optional argument to further configure its behavior. For instance, if your repository default branch is `main` instead of `master` (GitHub’s [new default](https://github.com/github/renaming)), you’ll need to add `default_branch: 'main'`:

``` text
change_in('/web/', { default_branch: 'main' })
```

Semaphore will re-run all jobs when we update the pipeline, even if no other files have changed. We can disable this behavior with `pipeline_file: 'ignore'`:

``` text
change_in('/web/', { pipeline_file: 'ignore' })
```

Another useful option is `exclude`, which lets us ignore files or folders.For example, we can ignore all Markdown files with:

``` text
change_in('/web/', { exclude: '/web/**/*.md' })
```

To see the rest of the options, check the [conditions YAML reference](https://docs.semaphoreci.com/reference/conditions-reference/)[^conditions].

[^conditions]: Conditions reference page - _<https://docs.semaphoreci.com/reference/conditions-reference/>_

## 2.4 Using change_in to Speed up Pipelines

In our CI pipeline there is no change detection yet; we'll remedy that now. Click on *Edit Workflow* to re-open the Workflow Builder.

On the first block, scroll down until you reach the section *Run/skip Conditions* and enable the option: “Run this block when conditions are met”.

Type the following condition: `change_in('/service1/', { default_branch: 'main'} )`. If your repository's default branch is `master` you can skip the `default_branch` option altogether.

![](./figures/03-change1.png){ width=85% }

Go to the second block and type this condition: `change_in('/service2/', { default_branch: 'main'} )`.

![](./figures/03-change2.png){ width=85% }

Click on *Run the Workflow* > *Start* to save the pipeline. Next, run the pipeline again. The first thing you’ll notice is that there's a new initialization step. Here, Semaphore is calculating differences in order to decide which blocks should run. You can check the log to see what is happening behind the scenes.

Once the workflow is ready, Semaphore will start running all jobs one more time (this happens because we didn’t set `pipeline_file: 'ignore' `). The interesting bit comes later, when we change a file in one of the applications.

``` bash
$ git pull
$ echo "modify service1" >> service1/README.md
$ git add service1
$ git commit -m "modify service1"
$ git push
```

This is what we get:

![](./figures/03-run2-done.png){ width=30% }

Two things have happened now that change-detection is enabled on the pipeline:

- A new initialization log is shown in the pipeline. The log is the output of Semaphore's initialization job, which reveals what folders or files have been marked as changed.
- Semaphore has detected that some parts of the monorepo have not changed and has skipped the related block. The improved pipeline can now selectively build the monorepo.

## 2.5 How Semaphore Identifies Changes

To understand what blocks will run each time, we must examine how `change_in` calculates the changed files in recent commits. The commit range varies depending on whether you’re working on `main/master` or a topic branch.

For the main branch, Semaphore compares the changes in all the commits for the push, then skips the `change_in` blocks that do not have at least one match.

![Commit ranges per push on master/main](./figures/03-git-master.png){ width=95% }

Semaphore takes a broader criteria for branches. The commit range goes from the point of the first commit that branched off the mainline to the branch’s head. This explains why Semaphore may choose to re-run blocks even on commits that seemingly don’t match the change criteria.

![For branches, commit ranges go from the main branch to the branch’s head](./figures/03-git-branch.png){ width=95% }

Pull requests behave similarly.

![For pull requests, commit ranges go from target branch to head of the branch](./figures/03-git-pr.png){ width=95% }

The commit range is defined from the first commit that branched off the branch targeted for merging to the head of the branch.

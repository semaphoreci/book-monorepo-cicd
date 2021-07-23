# 4. Change-based delivery

Change detection is not limited to blocks. We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

The main purpose of a promotion is to delivery software. Either by releasing a package or deploying it directly to the public. We can use promotions to start a pipeline that deploys an application into a cloud platform automatically, when all tests pass.

**Similar to the idea of showing something quick in the CI section before getting into the mud with Go, Elixir etc :)**

**I'd like to avoid talking about low-level details of deploying to Heroku or any other platform for 5 pages before saying anything about Semaphore.**

**Let's explore how it would look like to show a CD demo where jobs run echo but everything else is the real deal. Again, trying to optimize for quick understanding.**

### 4.1 Hello world continuous delivery

Promotions are created with the **Add Promotion** button. A pipeline can have multiple promotions.

PIC

A new pipeline is created, this pipeline works like any other, you can create blocks and jobs as usual.

PIC

By default, promotions are not automatic, this means that you need to manually start them by clicking on a button once the workflow has started. With a **manual** promotions, you must press a button and select the service to deploy from a list.

## 4.2 Secrets

## 4.3 Automatic conditions

Promotions can start automatically. This is achieved by checking the option **Enable automatic promotion**, rings a field to type the conditions that will trigger the next pipeline.

**Automatic** promotions start when specific conditions are detected, such as when a commit is pushed into a certain branch. The service to deploy is determined automatically.

Spending the time to think about when to trigger a promotions is key to avoid surprises. You can use a mix of the following conditions in Semaphore:

-   **branch**: detects when commits are pushed into a matching branch.
-   **tag**: runs when a tagged release is detected.
-   **pull request**: when the workflow was triggered by a pull request.
-   **change detection**: when Semaphore detects that some files have changed in given folders.

You should see an example snippet you can use as a starting point.

``` text
branch = 'main' AND results = 'passed'
```

This time, the promotion should start automatically, provided you are working on the `main` branch.

PIC

You can combine `change_in` and `branch = 'main' AND result = 'passed'` to start the pipeline when all jobs pass on the default branch.

``` text
change_in('/service1/') and branch = 'main' AND result = 'passed'
```

Once done, run the workflow to save the changes. From now on, when you make a change to the billing app, the new pipeline will start automatically if all tests pass on `master`.

PIC

## 4.4 Parametrized promotions

Parametrized promotions let us reuse a pipeline for similar tasks. For instance, you can create a deployment pipeline and share it among multiple applications in the monorepo. This way you have a unified process that simplifies delivery and cuts down on boilerplate.

A parametrized promotion works in tandem with environment variables. We define one or more variables and set default values based on conditions. 

PIC

In addition, when starting the promotion manually, we can set the value from a list or type it manually.

PIC

Parameters define global per-pipeline environment variables that we can access in all the job in it. We can even access their value in the pipeline name with:

``` text
${{ parameters.VARIABLE_NAME }}
```

We can even use parameters for secrets.

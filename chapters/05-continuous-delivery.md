# 4. Change-based delivery

Change detection is not limited to blocks. We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

The main purpose of a promotion is to delivery software. Either by releasing a package or deploying it directly to the public. We can use promotions to start a pipeline that deploys an application into a cloud platform automatically, when all tests pass.

## 4.1 Hello world continuous delivery

Promotions are created with the **Add Promotion** button. A pipeline can have multiple promotions.

![](./figures/05-add-promotion.png)

A new pipeline is created, this pipeline works like any other, you can create blocks and jobs as usual.

![](./figures/05-new-pipeline.png)

By default, promotions are not automatic, this means that you need to manually start them by clicking on a button once the workflow has started. With a **manual** promotions, you must press a button and select the service to deploy from a list.

![](./figures/05-manual-promotion.png)

## 4.2 Secrets

Telling Semaphore how to deploy software typicalling means storing your username and password, API keys, or other sensitive information as a secret. [Secrets](https://docs.semaphoreci.com/guided-tour/environment-variables-and-secrets/) are encrypted variables and files which are decrypted only when needed, in order to keep your data secure.

Secrets are found in the orzanization menu, in the **Settings** option.

![The settings menu](/Users/tom/rr/book-monorepo-cicd/chapters/figures/05-settings.png){ width=95% }

The **Secrets** menu lets you create new or edit existing secrets.

![](./figures/05-secret-menu.png)

A secret is, in short, an bunc h environment variables or files that are encrypted once you press **Save Secret**.

![](./figures/05-new-secret.png)

To use the secret in a job, you need to enable it at the block level. Checking the secret will make Semaphore decrypt the secret, import the environment variable and copy any attached files into the CI environment.

![](./figures/05-import-secret.png)

You can access the values like any other environment variable.

![](./figures/05-echo-secret.png)

## 4.3 Automatic conditions

Promotions can start automatically. This is achieved by checking the option **Enable automatic promotion**, rings a field to type the conditions that will trigger the next pipeline.

![](./figures/05-auto-promotion.png)

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

You can combine `change_in` and `branch = 'main' AND result = 'passed'` to start the pipeline when all jobs pass on the default branch.

``` text
change_in('/service1/') and branch = 'main' AND result = 'passed'
```

Once done, run the workflow to save the changes. From now on, when you make a change to the Billing app, the new pipeline will start automatically if all tests pass on `master`.

![](./figures/05-auto-promotion-done.png)

## 4.4 Parametrized promotions

Parametrized promotions let us reuse a pipeline for similar tasks. For instance, you can create a deployment pipeline and share it among multiple applications in the monorepo. This way you have a unified process that simplifies delivery and cuts down on boilerplate.

A parametrized promotion works in tandem with environment variables. We define one or more variables and set default values based on conditions. 

PIC (NEED UI)

In addition, when starting the promotion manually, we can set the value from a list or type it manually.

PIC

Parameters define global per-pipeline environment variables that we can access in all the job in it. We can even access their value in the pipeline name with:

``` text
${{ parameters.VARIABLE_NAME }}
```

We can even use parameters for secrets.

PIC

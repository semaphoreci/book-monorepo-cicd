## 4. Continuous Deployment for Monorepos

Chapter three left us with a working CI pipeline for the monorepo demo project. Having covered the basics, we can now focus on the final step: setting up a continuous deployment (CD).

The shift from CI to CD is subtle, but the differences are important. While everything that happens during CI is internal, a CD pipeline will necessarily interact with the external world, be it by publishing a package, updating a service, or deploying software. Extra care, thus, must be taken to avoid surprises.

Before we configure an automated deployment we'll need to master two new concepts:

- **Secrets**: they hold the access keys required to authenticate with external systems.
- **Promotions**: In most cases, continuous deployment in Semaphore happens via promotions

### 4.2 Secrets

Telling Semaphore how to deploy software typicalling means storing password, some API keys, or other sensitive information as a secret. [Secrets](https://docs.semaphoreci.com/guided-tour/environment-variables-and-secrets/) are encrypted variables and files that are decrypted into jobs on a need-to-know basis in order to keep your data secure.

Secrets can be accessed through the **Settings** option in the organization menu.

![The settings menu](./figures/05-settings.png){ width=95% }

The **Secrets** menu lets you create new or edit existing secrets.

![](./figures/05-secret-menu.png)

A secret is, in short, one or more variables or files. They are encrypted once you press **Save Secret**.

![](./figures/05-new-secret.png)

To use the secret in a job, you need to enable it at the block level. Enabling the secret will make Semaphore decrypt it, import the value as environment variables or copy attached files into the CI machine.

![](./figures/05-import-secret.png)

As you can see in the output of the log, you can access the secret value like any other environment variable. 

![](./figures/05-echo-secret.png)

### 4.1 Deploying with promotions

The main purpose of a promotion is to deliver software. While there are no fixed rules, the are usually places in the natural pause that exists between CI and CD.

Either by releasing a package or deploying it directly to the public, we can use promotions to start a pipeline that deploys an application into a cloud platform, provided all tests have passed.

Promotions can be created in the Workflow Editor with the **Add Promotion** button.

TODO: use demo instead

![](./figures/05-add-promotion.png)

Pressing the button will create a new pipeline. There's nothing especial about it, you can create blocks and jobs as usual.

![](./figures/05-new-pipeline.png)

By default, promotions are not automatic, whichhs means that you need to manually start them by clicking a button after the workflow has started.

![](./figures/05-manual-promotion.png)

*Auto-promotions* are activated when specific conditions are detected, such as when a commit is pushed into a certain branch. They are turned on by checking the **Enable automatic promotion** box and typing the criteria that will trigger the next pipeline.

![](./figures/05-auto-promotion.png)

Conditions are specified by mixing one or more of the following:

-   **branch**: evaluates to which branches the commit was made.
-   **tag**: used to detect a Git-tagged release.
-   **pull request**: when the workflow was triggered by a pull request.
-   **change detection**: if Semaphore detects that some files have changed in one or more given folders or files.

Once done, run the workflow to save the changes. From now on, when you make a change to the Billing app, the new pipeline will start automatically if all tests pass on `master`.

TODO: use demo

![](./figures/05-auto-promotion-done.png)

### 4.4 Parametrized promotions

Parametrized promotions let us reuse a pipeline for similar tasks. For instance, you can create a deployment pipeline and share it among multiple applications in the monorepo. This way you have a unified process that simplifies delivery and cuts down on boilerplate.

A parametrized promotion works in tandem with environment variables. We define one or more variables and set default values based on conditions. 

PIC (TODO NEED UI)

In addition, when starting the promotion manually, we can set the value from a list or type it manually.

PIC

Parameters define global per-pipeline environment variables that we can access in all the job in it. We can even access their value in the pipeline name with:

``` text
${{ parameters.VARIABLE_NAME }}
```

We can even use parameters for secrets.

PIC

. With a **manual** promotions, you must press a button and select the service to deploy from a list.

## 4.5 Staged deployments

Let's see how to apply what we learned to the deploying the demo. 

Since we want a sturdy CI/CD process. Testing the services in CI is no guarantee of zero errors in production, though. An extra degree on confidence is gained by using a staging environment.

We will need two new pipelines:

- **Staging**: runs the application in a production-like environment and run online tests.
- **Production**: if tests succeed, deploys into the production systems.

### 4.5.1 Staging the Users service

Everything is ready begin working in the staging pipeline. Begin by creating a new promotion and making it automatic. As said, the User service deploys on every change. This crystalizes as:

You should see an example snippet you can use as a starting point.

``` text
branch = 'main' AND results = 'passed'
```

Change detection is not limited to blocks. We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

You can combine `change_in` to start the pipeline when all jobs pass on the default branch.

``` text
change_in('/service1/') and branch = 'main' AND result = 'passed'
```

``` text
change_in('/services/users') AND result = 'passed'
```

Type the condition on the **when?** field

![](./figures/06-promote1.png){ width=95% }

In the same pane, immediately below you'll find the parameters section. Click **+add environment variable** and type the following conditions:

- **Name** of the variable: `SVC`
- **Description**: `Service to stage`
- **Valid options:** `users`,`billing`,`ui` (one per line)
- **Default value**: `users`

![](./figures/06-pp1.png){ width=40% }

What we're doing here is creating an environment variable, called `SVC`, which can take the values of any of our three services. When performing a manual promotion, you'll be able to pick the service from a list. On automatic promotions, the default value will be used.

Next, we'll create the staging pipeline. Click on the newly created pipeline and scroll down to **YAML file path**. Replace the default value with: `.semaphore/stage.yml`

Click on the new pipeline and set it's name to: `Stage ${{ parameters.SVC }}`. The `SVC` variable will be expanded dynamically the pipeline starts.

![](./figures/06-pp2.png){ width=95% }

We'll use the first block in the staging pipeline to deploy the staging application. Thanks to parametrization, `SVC` holds the application name. As for the `ENV`, we'll define it here, at the block level, as "staging". The combined commands are:

TODO

Ensure you’ve enabled any relevant secrets and set environment variables as required by your deployment target.

### 4.5.2 Smoke testing Users

Having a production-like environment is an invaluable opportunity for testing. We'll hack a quick test to check that the service is healthy.

Create a new block. In the job, we'll run some curl commands to create a user and check it exists afterward.

TODO

As per the plans we devised, auto-promotion criteria for Billing is:

``` text
change_in('/service/billing') AND result = 'passed' and tag=~ '.*'
```

And for the UI:

``` text
change_in('/service/ui') AND result = 'passed' AND branch = 'master'
```

The new promotions will have the same parameters, the variable name will be `ENV` and the valid options still `users`, `billing`, and `ui`. The **only** thing that changes is the default value: it will be `billing` in one and `ui` in the other.

Once you create the new promotions, Semaphore will create new empty pipelines. But we want to reuse the same staging pipeline. So, click on the new pipeline and change the **YAML file path** to `.semaphore/staging.yml`.

![](./figures/06-all-staging.png){ width=95% }

Do this for Billing and UI so every service is staged via the same pipeline.

### 4.5.3 Staging all the other services

## 4.6 The production pipeline

If testing on staging passed, chances are that it's pretty safe to continue with production. We only need one more pipeline, and we'll be done with the Users service.

### 4.6.1 Promoting Users to Production

TODO

The run down of the steps is:

1. Create a promotion branching off the staging pipeline, using the same auto-promotion and parameters as before.

   ![](./figures/06-deploypp1.png){ width=95% }

2. Ensure that `users` is the default value of the parametrized pipeline.

3. Rename the new pipeline as to: `.semaphore/deploy.yml`

4. Copy the deployment commands from the staging pipeline. They're fully parametrized, so there's no need to change them.

5. Activate the `heroku` secret.

6. Set `ENV = prod`

Click on **run the workflow** to give it a whirl. You may need to manually start the staging and deployment pipelines. Check that the Users service is deployed to both environments.

![](./figures/06-done2.png){ width=95% }

Click on **run the workflow** to give it a whirl. You may need to manually start the staging and deployment pipelines. Check that the Users service is deployed to both environments.

### 4.6.2 Deploying Billing and UI

The deploy to production pipeline can also be reused for the rest of the services. So, repeat the procedure: add two additional promotions branching of the stage pipeline and set the YAML pipeline file to `.semaphore/deploy.yml`.

At the end of the setup you will have a total of three pipelines (CI, staging, and production deploy), and six promotions.

![](./figures/06-pipelines-all.png){ width=95% }

## 5.6 Ready to go

The CI/CD process is 100% configured. The only thing left to do is save it and run it to ensure everything works as expected.

The resulting workflow is too big to see all at once on one page. Still, you can see the seven-pipeline overview in the project's dashboard.

TODO: take heroku out

![](./figures/06-final.png){ width=95% }

The deployment is complete as soon as everything is green. Good job and happy building!

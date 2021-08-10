\newpage

# 4. Continuous Deployment for Monorepos

Chapter three left us with a working CI pipeline. Now that we're through with the basics. Let's focus on the final stage of every CI/CD process: continuous deployment (CD), where we deploy the application services into production systems continually, without human intervention.

The shift from CI to CD is subtle but, in reality, it's a completely different ball game. While everything in CI happens, as it were, within the bounds of Semaphore's systems, a CD pipeline, be it by publishing a package, updating a service, or deploying software, will necessarily interact with the external world. Therefore, extra precautions must be taken to avoid surprises.

Before we configure an automated deployment, we'll need to master two Semaphore concepts:

- A **secret** holds the access keys required for authentication with external systems.
- **Promotions** connect the CI and CD pipelines together to create complex workflows.

## 4.1 Secrets

Telling Semaphore how to deploy software typically means storing a password, some API keys, or other sensitive information as a secret. [Secrets](https://docs.semaphoreci.com/essentials/using-secrets/)[^secrets] are encrypted variables and files that are decrypted into jobs on a need-to-know basis in order to keep your data secure.

[^secrets]: environment variables and secrets - _<https://docs.semaphoreci.com/essentials/environment-variables/>_

Secrets can be accessed through the **Settings** option in the organization menu.

![The settings menu](./figures/05-settings.png){ width=85% }

The *Secrets* menu lets you manage all the secrets within the organization.

![](./figures/05-secret-menu.png){ width=85% }

A secret is, in short, one or more variables or files, which are encrypted once you press *Save Secret*.

![](./figures/05-new-secret.png){ width=50% }

To use the secret in a job, you need to enable it at the block level. Enabling the secret will make Semaphore decrypt it, import the value as environmental variables or copy attached files into all the jobs in the block.

![](./figures/05-import-secret.png){ width=50% }

As you can see in the output of the log, you can access the secret value like any other environment variable.

![](./figures/05-echo-secret.png){ width=95% }

## 4.2 Deploying with Promotions

[Promotions](https://docs.semaphoreci.com/essentials/deploying-with-promotions/)[^promotions] connect pipelines together. While there are no fixed rules, they are usually placed in the natural "space" that exists between CI and CD.

[^promotions]: deploying with promotions - _<https://docs.semaphoreci.com/essentials/deploying-with-promotions/>_

Promotions are created via the *Add Promotion* button in the workflow editor. This will create a new pipeline.

![](./figures/05-add-promotion.png){ width=70% }

There's nothing special about this pipeline, you can create blocks and jobs as usual.

![](./figures/05-new-pipeline.png){ width=70% }

By default, promotions are not automatic, which means that you need to manually start them by clicking a button once the workflow has started.

![](./figures/05-manual-promotion.png){ width=70% }

*Auto-promotions* are activated when specific conditions are detected, such as when a commit is pushed into a certain branch. Checking the *Enable automatic promotion* box brings up a field to type the conditions that determine when the next pipeline starts.

![](./figures/05-auto-promotion.png){ width=50% }

Conditions are specified by mixing one or more of the following:

-   **branch**: evaluates to which branches the commit was made.
-   **tag**: used to detect a Git-tagged release.
-   **pull request**: used when the workflow was triggered by a pull request.
-   **change detection**: checks if files have changed in one or more selected folders or files.

The default conditions will make the new pipeline start when all tests pass on the `master` branch:

``` text
branch = 'master' AND result = 'passed'
```



![](./figures/05-auto-promotion-done.png){ width=98% }

## 4.3 Parametrized Promotions

Parametrized promotions let us reuse a pipeline for many tasks. For instance, you can create a deployment pipeline and share it among multiple applications in the monorepo, ensuring you have a unified release process for all the services.

Parametrized promotions work in tandem with environment variables — we define one or more variables and set default values based on the same conditional syntax we use in regular promotions.

To create a parameter, scroll down to the promotion pane and click *+Add Environment Variable*.

![](./figures/05-new-parameter.png){ width=50% }

When the promotion is started manually, we can choose a value from the list. With auto-promotions, however, the default value is used.

![](./figures/05-parameter-manual.png){ width=95% }

There are three important things to keep in mind while defining a parameter:

- Leaving the list of allowed values empty lets you type in any value, which opens the possibility for human errors.
- Parameters can be optional or mandatory. Required parameters must have a default value defined. Non-mandatory parameters can be empty.
- You can define multiple parameters in the same promotion.

Parameters define global, per-pipeline environment variables that jobs in it can access directly.

![](./figures/05-accessing-parameter.png){ width=95% }

## 4.4 Staging the Demo

Let's see how to apply what we learned to the deploying the demo.

We want a sturdy CI/CD process. Testing the services in CI is no guarantee of zero errors in production. A considerable degree of extra confidence can be gained by using a staging environment. Consequently, we will need two new pipelines:

- **Staging**: runs the application in a production-like environment and performs smoke tests.
- **Production**: if tests succeed, it deploys into the production systems.

### 4.4.1 Staging the Users Service

Begin by creating a new promotion and making it automatic. We'll deploy the User service on every change committed to the `master` branch. The auto-promotion condition will then be:

``` text
change_in('/services/users') AND results = 'passed' AND branch = 'master'
```

Type the condition into the *When?* field.

![](./figures/06-promote1.png){ width=99% }

In the same pane, immediately below, you'll find the parameters section. Click *+Add Environment Variable* and type the following:

- **Name** of the variable: `SVC`
- **Description**: Service to stage
- **Valid options:** `users`, `billing`, `ui` (one per line)
- **Default value**: `users`

![](./figures/06-pp1.png){ width=50% }

What we're doing here is creating an environmental variable, called `SVC`, that takes one of the three services in the repository.

Next, we'll create the staging pipeline. Click on the newly created pipeline and scroll down to the *YAML file path*. Replace the default value with `.semaphore/stage.yml`

Click on the new pipeline and set its name to: `Stage ${{ parameters.SVC }}`. The special syntax allows the `SVC` variable to be expanded dynamically once the pipeline begins running.

![](./figures/06-pp2.png){ width=95% }

We'll use the first block in the staging pipeline to deploy `SVC`. Type the deployment commands for this service. Add whichever secrets and environmental variables you need to release the new version into the staging environment.![](./figures/05-stage1.png){ width=95% }

If you need inspiration for setting up the jobs, we've written a lot about this on the Semaphore blog:

- What Is Canary Deployment: _<https://semaphoreci.com/blog/what-is-canary-deployment>_
- What Is Blue-Green Deployment: _<https://semaphoreci.com/blog/blue-green-deployment>_
- A Step-by-Step Guide to Continuous Deployment on Kubernetes: _<https://semaphoreci.com/blog/guide-continuous-deployment-kubernetes>_
- JavaScript Monorepos with Lerna: _<https://semaphoreci.com/blog/javascript-monorepos-lerna>_
- Android Continuous Integration and Deployment Tutorial: _<https://semaphoreci.com/blog/android-continuous-integration-deployment>_
- Python Continuous Integration and Deployment From Scratch: _<https://semaphoreci.com/blog/python-continuous-integration-continuous-delivery>_

### 4.4.2 Smoke Testing

Having a production-like environment presents an invaluable opportunity for testing. Let’s take a look at how Semaphore enables smoke tests.

Create a new block and add the commands required to check that the service is healthy. For example:	

``` bash
echo "Testing service $SVC"
curl "https://${SVC}.example.com"
```

![](./figures/05-smoke1.png){ width=95% }

### 4.4.3 Staging the Rest of the Services

Thanks to parametrization, our staging pipeline is universal. We can reuse it to stage the Billing and UI services.

Create a new promotion below to "Stage users". The criteria for releasing may be different for each service.  Let's say that we want to deploy Billing only on Git-tagged releases. Hence, the *When?* field should read:

``` text
change_in('/service/billing') AND result = 'passed' and tag=~ '.*'
```

![](./figures/05-billing-when.png){ width=95% }

The parameter for this promotion will be almost exactly the same as Users, the only difference is that the default value will be `billing` instead of `users`.

![](./figures/05-billing-svc.png){ width=50%}

Click on the newly-created pipeline and open the *YAML path* section. Replace the path of the file with `.semaphore/stage.yml`.

Repeat the same procedure with the UI Service:

1. Create a new promotion.
2. Type an auto-promotion condition.
3. Create a SVC parameter with a default value of `ui`.
4. Change the YAML path to `.semaphore/stage.yml`.

![](./figures/05-all-staging.png){ width=95% }

## 4.5 The Production Pipeline

If testing on staging passes, chances are that it's pretty safe to continue with production.

### 4.5.1 Promoting the Users Service to Production

We'll keep things simple by creating a deployment pipeline with one job. The rundown of the steps is:

1. Create a promotion branching off the staging pipeline, using the same auto-promotion and parameters as before.

   ![](./figures/06-deploypp1.png){ width=70% }

2. Ensure that `users` is the default value of the parametrized pipeline.

3. Rename the new pipeline to: `.semaphore/deploy.yml`

4. Type the deployment commands (the service to deploy is stored on the `SVC` variable).

5. Activate any required secrets and set environment variables as needed.

Click on *Run the Workflow* to give it a whirl. You may need to manually start the staging and deployment pipelines. Check that the Users service is deployed to both environments.

![](./figures/06-done2.png){ width=99% }

### 4.5.2 Deploying the Billing and UI Services

The deploy to production pipeline can also be reused for the rest of the services. So, repeat the procedure: add two additional promotions branching off the stage pipeline and set the *YAML pipeline* file to `.semaphore/deploy.yml`.

At the end of the setup you will have a total of three pipelines (CI, staging, and production deployment) connected by six promotions.

![](./figures/06-pipelines-all.png){ width=95% }

## 4.6 Ready to Go

The CI/CD process is 100% configured. The only thing left to do is save it and run it to ensure everything works as expected.

The resulting workflow is too big to see all at once on one page. Still, you can see the overview in the project's dashboard.

![](./figures/06-final.png){ width=95% }

The deployment is complete as soon as everything is green. Good job and happy building!

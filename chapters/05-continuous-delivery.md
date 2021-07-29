## 4. Continuous Deployment for Monorepos

Chapter three left us with a working CI pipeline. Now that we're through with the basics, we focus on the final stage of every CI/CD process: continuous deployment (CD), where we deploy the application services into production systems continually, without human intervention.

The shift from CI to CD is subtle, but, in reality, it's a completely different ball game. While everything in the CI happens, as it were, within the bounds of Semaphore networks, a CD pipeline, be it by publishing a package, updating a service, or deploying software, will necessarily interact with the external world. Therefore, extra precautions must be taken to avoid suprises.

Before we configure an automated deployment, we'll need to master two Semaphore concepts:

- **Secrets** hold the access keys required to authenticate with external systems.
- **Promotions** connect the CI and CD pipelines together, to create complex workflows.

### 4.1 Secrets

Telling Semaphore how to deploy software typicalling means storing a password, some API keys, or other sensitive information as a secret. [Secrets](https://docs.semaphoreci.com/guided-tour/environment-variables-and-secrets/)[^secrets] are encrypted variables and files that are decrypted into jobs on a need-to-know basis in order to keep your data secure.

[^secrets]: Environment variables and secrets
  https://docs.semaphoreci.com/essentials/environment-variables/

Secrets can be accessed through the **Settings** option in the organization menu.

![The settings menu](./figures/05-settings.png){ width=95% }

The **Secrets** menu lets manage all the secrets within the organization.

![](./figures/05-secret-menu.png)

A secret is, in short, one or more variables or files, which are encrypted once you press **Save Secret**.

![](./figures/05-new-secret.png)

To use the secret in a job, you need to enable it at the block level. Enabling the secret will make Semaphore decrypt it, import the value as environment variables or copy attached files into all the jobs in the block.

![](./figures/05-import-secret.png)

As you can see in the output of the log, you can access the secret value like any other environment variable. 

![](./figures/05-echo-secret.png)

### 4.1 Deploying with promotions

Promotions[^promotions] connect pipelines together. While there are no fixed rules, they are usually placed in the natural pause that exists between CI and CD.

[^promotions]: Deploying with promotions
  https://docs.semaphoreci.com/article/67-deploying-with-promotions

Promotions are created via the **Add Promotion** button in the workflow editor. This will create a new pipeline.

![](./figures/05-add-promotion.png)

There's nothing especial about this pipeline, you can create blocks and jobs as usual.

![](./figures/05-new-pipeline.png)

By default, promotions are not automatic, whichs means that you need to manually start them by clicking a button once the workflow has started.

![](./figures/05-manual-promotion.png)

*Auto-promotions* are activated when specific conditions are detected, such as when a commit is pushed into a certain branch. Checking the **Enable automatic promotion** box brings up a field to type the conditions[^conditions] that determine when the next pipeline starts.

[^conditions]: Conditions reference
  https://docs.semaphoreci.com/reference/conditions-reference/

![](./figures/05-auto-promotion.png)

Conditions are specified by mixing one or more of the following:

-   **branch**: evaluates to which branches the commit was made.
-   **tag**: used to detect a Git-tagged release.
-   **pull request**: used when the workflow was triggered by a pull request.
-   **change detection**: to check if some files have changed in one or more given folders or files.

The default conditions will make the new pipeline start when all test pass on the `master` branch:

``` text
branch = 'master' AND result = 'passed'
```



![](./figures/05-auto-promotion-done.png)

### 4.4 Parametrized promotions

Parametrized promotions let us reuse a pipeline for many tasks. For instance, you can create a deployment pipeline and share it among multiple applications in the monorepo, ensuring you have a unified release process for all the services.

Parametrized promotions work in tandem with environment variables — we define one or more variables and set default values based on the same condition syntax we use in regular promotions.

To create a parameter, scroll down on the promotion pane and click on **+ Add Environment Variable**.

![](./figures/05-new-parameter.png)

When the promotion is started manually, we can choose a value from the list. On auto-promotions, the default value is used.

![](./figures/05-parameter-manual.png)

There are three imporant things to keep in mind while defining a parameter:

- Leaving the list of allowed values empty lets you type in any value, which could potentially open the door to human errors.
- Parameters can be optional or mandatory. Required parameters must have a default value defined. Non-mandatory parameters can be empty.
- You can define multiple parameters in the same promotion.

Parameters define global, per-pipeline environment variables that jobs in it can access directly.

![](./figures/05-accessing-parameter.png)

## 4.5 Staging the demo

Let's see how to apply what we learned to the deploying the demo. 

We want a sturdy CI/CD process. Testing the services in CI is no guarantee of zero errors in production. An considerable extra degree on confidence is gained by using a staging environment. Consequently, we will need two new pipelines:

- **Staging**: runs the application in a production-like environment and performs smoke tests.
- **Production**: if tests succeed, deploys into the production systems.

### 4.5.1 Staging the Users service

Begin by creating a new promotion and making it automatic. We'll deploy the User service on every change commited to the `master` branch. The auto-promotion condition will then be:

``` text
change_in('/services/users') AND results = 'passed' AND branch = 'master' 
```

Type the condition on the **when?** field

![](./figures/06-promote1.png){ width=95% }

In the same pane, immediately below, you'll find the parameters section. Click **+Add Environment Variable** and type the following:

- **Name** of the variable: `SVC`
- **Description**: `Service to stage`
- **Valid options:** `users`,`billing`,`ui` (one per line)
- **Default value**: `users`

![](./figures/06-pp1.png){ width=40% }

What we're doing here is creating an environment variable, called `SVC`, that takes one of the three services in the repository When performing a manual promotion, you'll be able to pick the service from a list. On automatic promotions, the default value will be used.

Next, we'll create the staging pipeline. Click on the newly created pipeline and scroll down to **YAML file path**. Replace the default value with `.semaphore/stage.yml`

Click on the new pipeline and set it's name to: `Stage ${{ parameters.SVC }}`. The special syntax makes the `SVC` variable to be expanded dynamically once the pipeline begins running.

![](./figures/06-pp2.png){ width=95% }

We'll use the first block in the staging pipeline to deploy `SVC`. Type the deployment commands for this service. Add whatever secrets and environment variables you need to release the new version into the staging environment.![](./figures/05-stage1.png)

If you need inspiration for the commands, we've written a lot about this in the Semaphore blog:

TODO: list of interesting deployment tutorials

### 4.5.2 Smoke testing Users

Having a production-like environment is an invaluable opportunity for testing. 

Create a new block and add any commands required to check that the service is healthy.

``` bash
echo "Testing service $SVC"
curl "https://${SVC}.example.com"
```

![](./figures/05-smoke1.png)

### 4.5.3 Staging the rest of the services

Thanks to parametrization, our staging pipeline is universal. We can reuse it to stage the Billing and UI services.

Create a new promotion below to "Stage users". The criteria for releasing may be different for each service.  Let's say that we want to deploy Billing only on Git-tagged releases. Hence, the **When** should read:

``` text
change_in('/service/billing') AND result = 'passed' and tag=~ '.*'
```

![](./figures/05-billing-when.png)

The parameter for this promotion will be almost exactly the same as Users, the only difference is that the default value will be `billing` instead of `users`.

![](./figures/05-billing-svc.png)

Click on the newly-created pipeline and open the **YAML path** section. Replace the path of the file with `.semaphore/stage.yml`.

Repeat the same procedure with the UI Service:

1. Create new promotion.
2. Type an auto-promotion condition.
3. Create a SVC parameter with a default value of `ui`.
4. Change the YAML path to `.semaphore/stage.yml`.

![](./figures/05-all-staging.png){ width=95% }

## 4.6 The production pipeline

If testing on staging passed, chances are that it's pretty safe to continue with production.

### 4.6.1 Promoting Users to Production

We'll keep things simple by creating a deployment pipeline with one job. The rundown of the steps is:

1. Create a promotion branching off the staging pipeline, using the same auto-promotion and parameters as before.

   ![](./figures/06-deploypp1.png){ width=95% }

2. Ensure that `users` is the default value of the parametrized pipeline.

3. Rename the new pipeline as to: `.semaphore/deploy.yml`

4. Type the deployment commands. The service to deploy is stored on the `SVC` variable.

5. Activate any required secrets and set environment variables as needed.


Click on **Run the Workflow** to give it a whirl. You may need to manually start the staging and deployment pipelines. Check that the Users service is deployed to both environments.

![](./figures/06-done2.png){ width=95% }

### 4.6.2 Deploying Billing and UI

The deploy to production pipeline can also be reused for the rest of the services. So, repeat the procedure: add two additional promotions branching of the stage pipeline and set the **YAML pipeline** file to `.semaphore/deploy.yml`.

At the end of the setup you will have a total of three pipelines (CI, staging, and production deploy) connected by six promotions.

![](./figures/06-pipelines-all.png){ width=95% }

## 5.6 Ready to go

The CI/CD process is 100% configured. The only thing left to do is save it and run it to ensure everything works as expected.

The resulting workflow is too big to see all at once on one page. Still, you can see the overview in the project's dashboard.

TODO: update screenshot

![](./figures/06-final.png){ width=95% }

The deployment is complete as soon as everything is green. Good job and happy building!

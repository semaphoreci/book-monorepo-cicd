\newpage

# 3 Monorepo Continuous Deployment

The previous chapter left us with a working CI pipeline and a preliminary deployment step. Having covered the basics, we can now raise the bar and focus on setting up proper, real life continuous deployment (CD) pipelines.

## 3.1 Why Heroku

There are hundreds of services out there that can host our services. I’d like to be able to cover them all, with their nitty-gritty details. But, at the same time, I want this book to end at some point.

Having a uniform deployment process will help us keep things straight in our heads. On that account, [Heroku (<https://heroku.com>)](https://heroku.com) is almost a perfect fit for our needs: it supports all our languages — we can pretty much copy-and-paste the same commands across the board. And, best of all, we don't need a paid account or a credit card.

## 3.2 Prerequisites

You can continue from the point we left in the previous chapter. Nevertheless, if you want to start from a fresh copy, you may create a new project in Semaphore and choose the monorepo fork-and-run demo.

To follow along, you will need a Heroku account and its [management command-line interface (CLI)](https://devcenter.heroku.com/articles/heroku-cli). Follow the installation instructions for Windows, Linux, or Mac here:

[<https://devcenter.heroku.com/articles/heroku-cli>](https://devcenter.heroku.com/articles/heroku-cli)

When you have finished installing the CLI, type `heroku login` and follow the authentication process.

## 3.3 Initial deployment

We begin with a look at deploying the monorepo services as separate applications on Heroku. Later on, as we gain confidence, we’ll incorporate a staging step to run pre-production tests.

### 3.3.1 Application names and URLs

In short, we're going to create three apps, one for each service:

| Service | App Name              | Service URL                         |
| ------- | --------------------- | ----------------------------------- |
| users   | monorepo-users-prod   | monorepo-users-prod.herokuapp.com   |
| billing | monorepo-billing-prod | monorepo-billing-prod.herokuapp.com |
| ui      | monorepo-ui-prod      | monorepo-ui-prod.herokuapp.com      |

Since Heroku only allows **one global name per application**, you may have to experiment a bit until you find three free ones to use. As long as you keep the URLs and services sorted out, you should be fine.

The order in which we deploy the applications for the first time matters. The UI service must go last because it depends on Billing and Users, as you can see below.

![](./figures/04-service-dependency.png){ width=95% }

### 3.3.2 Preparing the services for deployment

We need to add a `Procfile` for each service, which tells what command starts the application.

Create the file `services/users/Procfile` with the following line to start the web service.

``` text
web: bundle exec ruby app.rb
```

Next, do the same with the rest of the services. To start the Billing service, we use:

``` text
web: bin/billing
```

The UI service starts with `mix start`:

``` text
web: mix run --no-halt
```

Moving on, create a new file called `service/ui/elixir_buildpack.config` with the following lines to define the Elixir and Erlang versions.

``` text
# elixir_buildpack.config
elixir_version=1.9
erlang_version=22.3
```

Those are all the modifications needed. Finally, write the changes back into your repository to finish the setup.

``` bash
$ git add services
$ git commit -m "Prepare for Heroku"
$ git push origin master
```

### 3.3.3 Deploying the first service

You can create an empty application on Heroku with the CLI or via the [dashboard](https://dashboard.heroku.com).

``` bash
$ heroku apps:create monorepo-users-prod
```

We can pretty much Git-push the code as-is to Heroku, and it will take care of rest. A neat trick is to create a disposable repository, thus ensuring we don't mess with the main monorepo Git history.

``` bash
$ cd services/users
$ git init -b master
$ heroku git:remote -a monorepo-users-prod
$ git add .
$ git commit -m "first deployment"
$ git push heroku master
```

The Users service should be online. Visiting the URL should return an empty JSON array.

``` bash
$ curl "https://monorepo-users.herokuapp.com/users"
[]
```

After you confirm the deployment is complete, you can delete the temporary Git repository.

``` bash
# make sure you’re at /services/users
$ rm -r .git
```

### 3.3.4 Deploying the other services

Time to deploy Billing and UI. From the root of the repository run:

``` bash
$ cd services/billing
$ heroku apps:create monorepo-billing-prod
$ git init -b master
$ heroku git:remote -a monorepo-billing-prod
$ git add .
$ git commit -m "first deployment"
$ git push heroku master
$ rm -r .git
```

The UI service needs a little more work to set up, as Heroku cannot detect Elixir projects by itself.

``` bash
$ heroku create --buildpack hashnuke/elixir monorepo-ui
```

The UI also needs to know the URLs of the other services. So we set environment variables to point to the correct endpoints (update the values as required).

``` bash
$ heroku config:set --app=monorepo-ui-prod \
         BILLING_ENDPOINT=https://monorepo-billing-prod.herokuapp.com/
$ heroku config:set --app=monorepo-ui \
         USERS_ENDPOINT=https://monorepo-users-prod.herokuapp.com/
```

Finally, from the root of the repository, run:

``` bash
$ cd services/ui
$ git init -b master
$ heroku git:remote -a monorepo-ui-prod
$ git add .
$ git commit -m "first deployment"
$ git push heroku master
$ rm -r .git
```

Good! The three services should now be online:

``` bash
$ heroku list
== tom@example.com Apps
monorepo-billing-prod
monorepo-ui-prod
monorepo-users-prod
```

## 3.4 Continuous Deployment

With the services online, the plan now is to automate things, so we don't need to worry about deploying new versions by hand on each update.

In order to reduce code duplication and standardize the deployment, we'll use *parametrized promotions*. These work like the promotions we've seen in the previous chapter, with the added benefit that we can set pipeline-wide environment variables based on different conditions.

We will need two new pipelines:

- **Staging**: runs the application in a production-like environment and run online tests.
- **Production**: if tests succeed, deploys into the production URL.

### 3.4.1 Staging application names and URLs

We want a sturdy CI/CD process. Testing the services in CI is no guarantee of zero errors in production, though. An extra degree on confidence is gained by using a staging environment.

Since creating an app doesn't cost anything, let's create three new staging apps:

| Service | Staging App Name         |
| ------- | ------------------------ |
| users   | monorepo-users-staging   |
| billing | monorepo-billing-staging |
| ui      | monorepo-ui-staging      |

Before moving on, **create the three new staging apps**. Use the same commands as in section 3.5 replacing `-staging` with `-prod`.

When done, you should have six applications in total:

``` bash
$ heroku list
=== tom@tomfern.com Apps
monorepo-billing-prod
monorepo-billing-staging
monorepo-ui-prod
monorepo-ui-staging
monorepo-users-prod
monorepo-users-staging
```



### 3.4.2 Deployment methods

Deployment can be manual or automatic. Semaphore supports both types.

-   With a **manual** deployment, you must press a button and select the service to deploy from a list.
-   **Automatic** deployments start when specific conditions are detected, such as when a commit is pushed into a certain branch. The service to deploy is determined automatically.

Spending the time to think about when to trigger a deployment is key to avoid surprises. You can use a mix of the following conditions in Semaphore:

-   **branch**: detects when commits are pushed into a matching branch.
-   **tag**: runs when a tagged release is detected.
-   **pull request**: when the workflow was triggered by a pull request.
-   **change detection**: when Semaphore detects that some files have changed in given folders.

You can mix and match the criteria to fit your needs. Here's an idea:

| Service | change-detection              | branches | tags        |
|---------|-------------------------------|----------|-------------|
| users   | change_in('/service/users')   | any      | any         |
| billing | change_in('/service/billing') | any      | must be set |
| ui      | change_in('/service/ui')      | master   | any         |

All changes in Users will be deployed as long as tests pass. In Billing, on the other hand, we'll only deploy tagged releases. Lastly, in UI, we'll deploy changes once merged to the master branch.

### 3.4.3 Secrets and variables

Telling Semaphore how to deploy means storing your username and password as a secret. [Secrets](https://docs.semaphoreci.com/guided-tour/environment-variables-and-secrets/) are encrypted variables and files which are decrypted only when needed, in order to keep your data secure.

At the beginning of this chapter, after installing the Heroku CLI, you authenticated with the platform from your machine. A similar process must happen now in Semaphore. It must gain access to the account in order to deploy on your behalf.

First, get the active Heroku username and token with:

``` bash
$ heroku auth:whoami
tom@example.com

$ heroku auth:token
392a5736-16e5-38d6-bea4-636c7e473d1d
```

Next, open the settings menu on Semaphore.

![The settings menu](./figures/04-settings.png){ width=95% }

Create a new secret with two variables: `HEROKU_EMAIL` and `HEROKU_API_KEY` with the email and token.

![](./figures/04-heroku-secret.png){ width=95% }

We’ll learn how to import the secret on the job in a minute.

### 3.4.4 Parametrized promotions

Everything is ready begin working in the staging pipeline. Begin by creating a new promotion and making it automatic. As said, the User service deploys on every change. This crystalizes as:

``` text
change_in('/services/users') AND result = 'passed'
```

Type the condition on the **when?** field.

![](./figures/04-promote1.png){ width=95% }



In the same pane, immediately below you'll find the parameters section. Click **+add environment variable** and type the following conditions:

- **Name** of the variable: `SVC`
- **Description**: `Service to stage`
- **Valid options:** `users`,`billing`,`ui` (one per line)
- **Default value**: `users`

![](./figures/04-pp1.png){ width=95% }

What we're doing here is creating an environment variable, called `SVC`, which can take the values of any of our three services. When performing a manual promotion, you'll be able to pick the service from a list. On automatic promotions, the default value will be used.

### 3.4.5 Staging pipeline

Next, we'll create the staging pipeline. Click on the newly created pipeline and scroll down to **YAML file path**. Replace the default value with: `.semaphore/stage.yml`

Click on the new pipeline and set it's name to: `Stage ${{ parameters.SVC }} to Heroku`. The `SVC` variable will be expanded dynamically the pipeline starts.

![](./figures/04-pp2.png){ width=95% }

We'll use the first block in the staging pipeline to deploy the staging application. Thanks to parametrization, `SVC` holds the application name. As for the `ENV`, we'll define it here, at the block level, as "staging". The combined commands are:

``` bash
checkout
cd "services/$SVC"
git init
git config user.email "$HEROKU_EMAIL"
git config user.name "$HEROKU_EMAIL"
git config credential.helper '!f() { printf "%s\n" "username=''$HEROKU_EMAIL''" "password=''$HEROKU_API_KEY''"; };f'
heroku git:remote -a "monorepo-${SVC}-${ENV}"
git add .
git commit -m "deploy monorepo-${SVC}-${ENV} to Heroku"
git push heroku master --force
```

![](./figures/04-stage1.png){ width=95% }

Let’s break down the commands:
1. Create an empty application.
2. Clone the repository in the CI environment.
3. Initialize a Git repository, configure the username and email.
4. Initialize a helper function that returns the Heroku API key to Git.
5. Push the files with Git.

Two more things to go. One, open the **environment** section in the block and set the `ENV = staging`. And two, scroll down to the **secrets** part and check the `heroku` secret. Now the job has access to the Heroku API key.

![](./figures/04-env1.png){ width=95% }



### 3.4.6 The test job

Having a production-like environment is an invaluable opportunity for testing. We'll hack a quick test to check that the service is healthy.

Create a new block. In the job, we'll run some curl commands to create a user and check it exists afterward.

``` bash
curl "https://monorepo-${SVC}-${ENV}.herokuapp.com"
```

The only thing left is to set the correct `ENV` in the environment, like you did in the previous block.

![](./figures/04-tests1.png){ width=95% }

## 3.5 Production Pipeline

If testing on staging passed, chances are that it's pretty safe to continue with production. We only need one more pipeline, and we'll be done with the Users service.

The run down of the steps is:

1. Create a promotion branching off the staging pipeline, using the same auto-promotion and parameters as before.

   ![](./figures/04-deploypp1.png){ width=95% }

2. Ensure that `users` is the default value of the parametrized pipeline.

3. Rename the new pipeline as to: `.semaphore/deploy.yml`

4. Copy the deployment commands from the staging pipeline. They're fully parametrized, so there's no need to change them.

5. Activate the `heroku` secret.

6. Set `ENV = prod`

Click on **run the workflow** to give it a whirl. You may need to manually start the staging and deployment pipelines. Check that the Users service is deployed to both environments.

![](./figures/04-done2.png){ width=95% }

### 3.5.1 Connecting all pipelines with promotions

Since we kept all pipelines reusable with variables and parameters, it's easy to reproduce the staging and deployment pipelines for the rest of the services in the monorepo.

To recap, we need two more automatic promotions.

![](./figures/04-promotions-all.png){ width=95% }

### 3.5.2 Stage parameters for Billing and UI

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

![](./figures/04-all-staging.png){ width=95% }

Do this for Billing and UI so every service is staged via the same pipeline.

### 3.5.3 Production pipelines for Billing and UI

The deploy to production pipeline can also be reused for the rest of the services. So, repeat the procedure: add two additional promotions branching of the stage pipeline and set the YAML pipeline file to `.semaphore/deploy.yml`.

At the end of the setup you will have a total of three pipelines (CI, staging, and production deploy), and six promotions.

![](./figures/04-pipelines-all.png){ width=95% }

## 3.6 Ready to go?

The CI/CD process is 100% configured. The only thing left to do is save it and run it to ensure everything works as expected.

The resulting workflow is too big to see all at once on one page. Still, you can see the seven-pipeline overview in the project's dashboard.

![](./figures/04-final.png){ width=95% }

The deployment is complete as soon as everything is green. Good job and happy building!

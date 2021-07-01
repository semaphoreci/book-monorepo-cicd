\newpage

# Monorepo Continuous Deployment

The previous chapter left us with a working CI pipeline and a preliminary deployment step. Having covered the basics, we can now focus on setting up proper continuous deployment (CD).

## Why Heroku

There are hundreds of services out there that can host our services. I aspire to cover all the nitty-gritty details needed to send out the applications in the monorepo into the world. But, at the same time, I want this book to end at some point.

Having a uniform deployment process will help us keep things straight. On that account, [Heroku (<https://heroku.com>)](https://heroku.com) is almost a perfect fit for our demo project. It supports all the languages used so far: Go, Ruby, and Elixir—we can pretty much copy-and-paste the same deployment commands everywhere. And, best of all, we don't need a paid account or a credit card to try it out.

## Prerequisites

You can continue from the point left in the previous chapter. Nevertheless, if you want to start from a fresh copy, create a new project on Semaphore and, in the <u>Try a quick experiment</u> section, choose the monorepo example. This will fork and clone the demo project in your GitHub account.

To follow along, you will need a Heroku account and its [management command-line interface (CLI)](https://devcenter.heroku.com/articles/heroku-cli). Follow the installation instructions for Windows, Linux, or Mac here:

[<https://devcenter.heroku.com/articles/heroku-cli>](https://devcenter.heroku.com/articles/heroku-cli)

When you have finished installing the CLI, type `heroku login` and follow the authentication process.

## Deployment strategy

We begin with a look at deploying the monorepo services as separate applications on Heroku. Later on, we'll see how to incorporate a staging step to run tests on a live environment before deployment occurs.

In other words, we're going to create three apps, one for each service.

| Service | App Name         | Service URL                    |
|---------|------------------|--------------------------------|
| users   | monorepo-users   | monorepo-users.herokuapp.com   |
| billing | monorepo-billing | monorepo-billing.herokuapp.com |
| ui      | monorepo-ui      | monorepo-ui.herokuapp.com      |

Since Heroku only allows one global name per application, you may have to experiment a bit until you find three free ones to use. As long as you keep the URLs and services sorted out, any name should work.

The order in which we deploy the applications the first time matters. The UI service depends on Billing and Users, as you can see below. Consequently, we need to leave the UI for last.

![](./figures/04-service-dependency.png)

## Preparing the services for deployment

We can pretty much push the code as-is using Git. We only need to add a `Procfile` for each service, which tells Heroku how to start it.

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

## Deploying the first service

You can create an empty application on Heroku with the CLI or via the [dashboard](https://dashboard.heroku.com).

``` bash
$ heroku apps:create monorepo-users
```

Deployment starts with a Git push. A neat trick is to create a disposable repository, thus ensure we don't mess with the monorepo Git history.

``` bash
$ cd services/users
$ git init -b master
$ heroku git:remote -a monorepo-users
$ git add .
$ git commit -m "first deployment"
$ git push heroku master
```

The Users service should be online. Visiting the URL should return an empty JSON array.

$ curl <https://monorepo-users.herokuapp.com/users> \[\]

After you confirm the deployment is complete, you can delete the temporary Git repository.

``` bash
$ rm -rf .git
```

## Deploying all services

Time to deploy Billing and UI. From the root of the repository run:

``` bash
$ cd services/billing
$ heroku apps:create monorepo-billing
$ git init -b master
$ heroku git:remote -a monorepo-billing
$ git add .
$ git commit -m "first deployment"
$ git push heroku master
```

The UI service needs a little more work to set up, as Heroku cannot detect Elixir projects by itself.

``` bash
$ heroku create --buildpack hashnuke/elixir monorepo-ui
```

The UI also needs to know the URLs of the other services. So we set environment variables to point to the correct endpoints (update the values as required).

``` bash
$ heroku config:set --app=monorepo-ui BILLING_ENDPOINT=https://monorepo-billing.herokuapp.com/
$ heroku config:set --app=monorepo-ui USERS_ENDPOINT=https://monorepo-users.herokuapp.com/
```

Finally, from the root of the repository, run:

``` bash
$ cd services/ui
$ git init -b master
$ heroku git:remote -a monorepo-ui
$ git add .
$ git commit -m "first deployment"
$ git push heroku master  (cuidado con master vs main)
$ rm -rf .git
```

Good! The three services should now be online:

$ heroku list `=` tom@example.com Apps monorepo-billing monorepo-ui monorepo-users

## Continuous Deployment

With the services online, the trick now is to automate things, so we don't need to worry about deploying new versions.

### Staging environment

We want a sturdy CI/CD process. Testing the services in CI is no guarantee of zero errors in production, though. We gain an extra degree of confidence by using a staging environment.

Each service will have a separate temporary staging app on Heroku:

| Service | Staging Name             |
|---------|--------------------------|
| users   | monorepo-users-staging   |
| billing | monorepo-billing-staging |
| ui      | monorepo-ui-staging      |

Deployment can be manual or automatic:

-   **Manual**: staging and production deployments must be started by pressing a button on the Semaphore workflow. Presumably, after doing some exploratory testing.
-   **Automatic**: Semaphore will start the staging and production deployments on specific conditions.

Spending the time to think about when to trigger a deployment is key to avoid surprises. You can use a mix of the following conditions in Semaphore:

-   **branch**: triggered when the commit was applied to a specific branch or branch matching a regex expression.
-   **tag**: for commits that were pushed as a tag. You can filter tags using regex.
-   **pull request**: when the workflow was triggered by a pull request.
-   **change detection**: when Semaphore detects that some files have changed in given folders.

You can mix and match the criteria to fit your needs. For example:

<div id="promotion-strategy">

| Service | change-detection              | branches | tags        |
|---------|-------------------------------|----------|-------------|
| users   | change_in('/service/users')   | any      | any         |
| billing | change_in('/service/billing') | any      | must be set |
| ui      | change_in('/service/ui')      | master   | any         |

</div>

For **users** we'll just deploy all changes where tests have passed. In **billing**, on the other hand, we'll only deploy tagged changes. Lastly, in **ui**, we'll deploy changes once merged to the master branch.

### Secrets and variables

Telling Semaphore how to deploy means storing your username and password as a secret. [Secrets](https://docs.semaphoreci.com/guided-tour/environment-variables-and-secrets/) are encrypted and decrypted only when needed to keep your data secure.

At the beginning of this chapter, after installing the Heroku CLI, you authenticated with the platform. A similar process must happen now in Semaphore. It must gain access to your account in order to deploy on your behalf.

First, get the active Heroku username and token with:

``` bash
$ heroku auth:whoami
tom@example.com
```

``` bash
$ heroku auth:token
392a5736-16e5-38d6-bea4-636c7e473d1d
```

Next, open the settings menu on Semaphore.

![The settings menu](./figures/04-settings.png)

And go to **secrets**. Secrets are encrypted environment variables and files used to store sensitive data.

Create a new secret with two variables: `HEROKU_EMAIL` and `HEROKU_API_KEY` with the email and token.

![](./figures/04-heroku-secret.png)

## Staging pipelines

Everything is ready to set up the staging pipeline. Begin by creating a new promotion and making it automatic. As said, the User service deploys on every change. This crystalizes as this promotion condition:

``` text
change_in('/services/users') AND result = 'passed'
```

![](./figures/04-promote1.png)

We'll use the first block in the staging pipeline to create a brand new staging application and deploy its service. The combined commands for this are:

``` bash
heroku apps:create "$APP_NAME"
checkout
cd services/users
git init
git config user.email "$HEROKU_EMAIL"
git config user.name "$HEROKU_EMAIL"
git config credential.helper '!f() { printf "%s\n" "username='$HEROKU_EMAIL'" "password='$HEROKU_API_KEY'"; };f'
heroku git:remote -a "$APP_NAME"
git add .
git commit -m "deploy $APP_NAME to Heroku"
git push heroku master --force
```

![](./figures/04-stage1.png)

We'll use environment variables to keep the job commands reusable. For example, by appending `-staging` to the name.

Open the **environment** section in the block and set the APP_NAME.

``` bash
APP_NAME=monorepo-users-staging
```

![](./figures/04-env1.png)

Scroll down to the **secrets** part and check the `heroku` secret.

### Test job

Having a production-like environment is an invaluable opportunity for testing. We'll hack a quick test to check that the User service is healthy.

Create a new block. In the job, we'll run some curl commands to create a user and check it exists afterward.

``` bash
curl --location --request POST "${APP_NAME}.herokuapp.com/users" --header 'Content-Type: application/json' --data-raw '{ "name": "Rodrigo Amarante" }'
sleep 1
[[ $(curl --location --request GET "${APP_NAME}.herokuapp.com/users" --header 'Accept: application/json') == '[{"id":0,"name":"Rodrigo Amarante"}]' ]]
```

Regardless of tests succeeding or not, we should tidy up and delete the staging environment. To do that, open the **epilogue**, and type the following command:

``` bash
heroku apps:delete "$APP_NAME" --confirm "$APP_NAME"
```

The only thing left is to set the correct APP_NAME in the environment.

![](./figures/04-tests1.png)

## Deploy to Production Pipelines

If testing on staging passed, chances are that it's pretty safe to continue with production. We only need one more pipeline, and we'll be done with the Users service.

Create a promotion branching off the staging pipeline. You may use the same auto-promotion conditions. On the new pipeline job, type these deployment commands, define the environment variable (this time with the production application name), and activate the secret.

``` bash
checkout
cd services/users
git init
git config user.email "$HEROKU_EMAIL"
git config user.name "$HEROKU_EMAIL"
git config credential.helper '!f() { printf "%s\n" "username='$HEROKU_EMAIL'" "password='$HEROKU_API_KEY'"; };f'
heroku git:remote -a "$APP_NAME"
git add .
git commit -m "deploy $APP_NAME to Heroku"
git push heroku master --force
```

![](./figures/04-deploy1.png)

Give it a whirl. Run the workflow; you may need to manually start the staging and deployment pipelines.

![](./figures/04-done2.png)

### Rinse and repeat

Since we kept all commands reusable with variables, it's easy to reproduce the staging and deployment pipelines for the rest of the services in the monorepo. You only need to adjust `APP_NAME`.

To recap, we need two more staging pipelines.

![](./figures/04-promotions-all.png)

And two extra production deployment pipelines, which brings us to a total of seven pipelines.

![](./figures/04-pipelines-all.png)

As per the plans we devised, auto-promotion criteria for Billing is:

``` text
change_in('/service/billing') AND result = 'passed' and tag=~ '.*'
```

And for the UI:

``` text
change_in('/service/ui') AND result = 'passed' AND branch = 'master'

```

## Ready to go?

The CI/CD process is 100% configured. The only thing left to do is save it and run it to ensure everything works as expected.

The resulting workflow is too big to see all at once on one page. Still, you can see the seven-pipeline overview in the project's dashboard.

![](./figures/04-final.png)

The deployment is complete as soon as everything is green. Good job and happy building!

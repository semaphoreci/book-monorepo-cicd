\newpage

# 3. Continuous Integration Demo

How many projects must a repository accumulate before it can be called a monorepo? More than one? Tens, hundreds? Do we need to hold back until dedicated tools to manage it are needed?

There's not pat answer. We have prepared a demo, and it's made of three projects. It works well to show how every piece we've seen thus far fits together. And it will act as a springboard that takes us into continuous delivery in the next chapter.

## 3.1 Monorepo Demo

As said, the demo we're using from now on is divided in three microservices. The code is located in the `services` folder

- `/services/user`: a Ruby-based user registration service. Exposes a HTTP REST endpoint.

-   `/services/billing`: written in Go, stores payment details.
-   `/services/ui`:  is the frontend, written in Elixir.

All these parts are meant to work together, but each one may be maintained by a separate team and written in a different language.

Before moving on, go ahead fork the repository and clone it into your machine:

_[https://github.com/semaphoreci-demos/semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo)_

## 3.2 Setting up the Pipeline

To begin, create a new project in Semaphore and select the demo. Alternatively, if you prefer to jump directly to the final state, find the monorepo example and click the **fork & run** button.

The repository ships with a ready-to-use pipeline, but we'll learn a lot more by manually setting it up from zero. Hence, when prompted, click on "I want configure this project from scratch.”

![Create a new pipeline](./figures/04-scratch.png){ width=70% }

We’ll start with the Billing application. Find the **Go starter workflow** and click on **customize**:

![Select the Go starter workflow](./figures/04-go-starter.png){ width=95% }

### 3.2.1 Billing Service

Next, modify the starter template job in two places:

1.  The app has been tested on Go version 1.14+. So, add this line to the beginning of the job `sem-version go 1.14`.
2.  Since the code is located in the `services/billing` folder, add `cd services/billing` after `checkout`.

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

The last three commands use Go's built-in toolset to download dependencies, test, and build the microservice.

![Build job for billing app](./figures/04-go-build1.png){ width=95% }

### 3.2.2 Users Service

Let’s add a second application to the pipeline. Create a new block. Then, add the commands to install and test the Ruby app:

``` bash
sem-version ruby 2.5
checkout
cd services/users
cache restore
bundle install
cache store
bundle exec ruby test.rb
```

![No dependencies in the User block](./figures/04-no-dep-user.png){ width=95% }

And **uncheck** all the checkboxes under Dependencies.

![](./figures/05-uncheck-billing.png){ width=95% }

### 3.2.3 UI Service

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

## 3.3 Configuring Change Detection

You can try running the pipeline now, just to make sure everything is in order. Now, what happens if we change a file inside the `/services/ui` folder?

![All blocks running](./figures/04-all-blocks1.png){ width=40% }

Yeah, despite only one of the projects has changed, all the blocks are running. For a big monorepo with hundreds of projects, that’s a lot restless hours of waiting accumulated every  week. We can do better.

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

With `change_in` in place, Semaphore will only work on those microservices that were recently changed.

![Running all blocks](./figures/04-skip-but-billing.png){ width=40% }

Can you guess which application I changed? Yes, that’s right: it was the Billing app. As a result, thanks to `change_in`, the rest of the blocks have been skipped because neither did meet the change conditions.

If we make a change outside any of the monitored folders, then all the blocks are skipped and the pipeline completes in just a few seconds.

![Skipping all blocks](./figures/04-skip-all.png){ width=40% }

## 2.6 Tips for Using change_in

Tying up a block with a piece of the code results in a smarter pipeline that builds and tests only what has recently changed.

Scaling up large monorepos with `change_in` is easier if you follow these tips for organizing your code and pipelines:

-   Define a unified folder organization, so you can use clean change conditions.
-   Design your blocks around project folders.
-   When needed, add multiple files and folders to `change_in`. Use this to rebuild all the connected project components within a monorepo.
-   Keep branches small, and merge them frequently to cut build times.
-   Use `exclude` and wildcards to ignore files that are not relevant, such as documentation or READMEs.
-   Use `change_in` in auto-promotions to selectively trigger continuous delivery or deployment pipelines.

In the next section we'll learn how to apply this principle to continuous delivery. We'll also learn a few more key concepts that will play a key role in automatic deployments later on.


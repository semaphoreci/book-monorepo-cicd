\newpage

# 3. Change detection demo

Real world applications tend to be much more complex that the example we've seen in the previous chapter. Thus, we have prepared a monorepo demo as a starting point that you can use to practice on a level that's near what developers may encounter in their day to day.

## 3.1 Cloning the demo

The demo we're going to work with is made of three microservices:

-   `/service/billing`: written in Go, calculates user payments.
-   `/service/user`: a Ruby-based user registration service. Exposes a HTTP REST endpoint.
-   `/service/ui`: which is a web UI component. Written in Elixir.

All these parts are meant to work together, but each one may be maintained by a separate team and written in a different language.

Before moving on, go ahead, fork the repository and clone it into your machine:

_[https://github.com/semaphoreci-demos/semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo)_

## 3.2 Setting up the pipeline

To begin, create a new project in Semaphore and select the demo. Alternatively, if you prefer to jump directly to the final state, find the monorepo example and click on **fork & run**.

The demo ships with a ready-to-use pipeline, but we'll learn a lot more by manually setting it up. Hence, when prompted, click on "I want configure this project from scratch.”

![Create a new pipeline](./figures/04-scratch.png){ width=70% }

We’ll start with the Billing application. Find the **Go starter workflow** and click on **customize**:

![Select the Go starter workflow](./figures/04-go-starter.png){ width=95% }

### 3.2.1 Billing service

You have to modify the job a bit before it works:

1.  The app has been tested on Go version 1.14+. So, add this line to the beginning of the job `sem-version go 1.14`.
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

The last three commands use Go's built-in toolset to download dependencies, test and build the micro service.

![Build job for billing app](./figures/04-go-build1.png){ width=95% }

### 3.2.2 Users service

Let’s add a second application in the pipeline. Add a new block. Then, add the commands to install and test a Ruby application.

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

![](./figures/05-uncheck-billing.png)

### 3.2.3 UI service

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

## 3.3 Configuring change detection

You can try running the pipeline now, just to make sure everything is in order. Now, what happens if we change a file inside the `/services/ui` folder?

![All blocks running](./figures/04-all-blocks1.png){ width=40% }

Yeah, despite only one of the projects has changed, all the blocks are running. This is… not optimal. For a big monorepo with hundreds of projects, that’s a lot of wasted hours, with added boredom and axiety for software developers. The good news is that this is a perfect fit for trying out change-based execution.

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

With change_in in place, Semaphore will only work on those microservices that were recently changed.

Can you guess which application I changed? Yes, that’s right: it was the Billing app. As a result, thanks to `change_in`, the rest of the blocks have been skipped because neither did meet the change conditions.

![Running all blocks](./figures/04-skip-but-billing.png){ width=40% }

If we make a change outside any of the monitored folders, then all the blocks are skipped and the pipeline completes in just a few seconds.

![Skipping all blocks](./figures/04-skip-all.png){ width=40% }

## 2.6 Tips for using change_in

Tying up a block with a piece of the code results in a smarter pipeline that builds and tests only what has recently changed.

Scaling up large monorepos with `change_in` is easier if you follow these tips for organizing your code and pipelines:

-   Define a unified folder organization, so you can use clean change conditions.
-   Design your blocks around project folders.
-   When needed, add multiple files and folders to `change_in`. Use this to rebuild all the connected project components within a monorepo.
-   Keep branches small, and merge them frequently to cut build times.
-   Use `exclude` and wildcards to ignore files that are not relevant, such as documentation or READMEs.
-   Use `change_in` in auto-promotions to selectively trigger continuous delivery or deployment pipelines.

In the next section we'll learn how to apply this principle to continuous delivery. We'll also learn a few more key concepts that will play a key role in automatic deployments later on.


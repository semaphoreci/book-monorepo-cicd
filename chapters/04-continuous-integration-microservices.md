\newpage

# 3. Change detection for microservices

## 3.1 Cloning the demo

In this section, we’ll set up a monorepo pipeline. We’ll use the [semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo) project as a starting point, but you can adapt these steps to any CI/CD workflow on Semaphore.

Go ahead and fork the repository:

_[https://github.com/semaphoreci-demos/semaphore-demo-monorepo](https://github.com/semaphoreci-demos/semaphore-demo-monorepo)_

The repo contains three projects, each one in a separate folder:

-   `/service/billing`: written in Go, calculates user payments.
-   `/service/user`: a Ruby-based user registration service. Exposes a HTTP REST endpoint.
-   `/service/ui`: which is a web UI component. Written in Elixir.

All these parts are meant to work together, but each one may be maintained by a separate team and written in a different language.

## 3.2 Setting up the pipeline

Next, log in with your Semaphore account and click on **create new** on the upper left corner.

Now, choose the repository you forked. Alternatively, if you prefer to jump directly to the final state, find the monorepo example and click on **fork & run**.

You can add people to the project at this point. When you’re done, click **Continue** and select “I want to configure this project from scratch.”

![Create a new pipeline](./figures/04-scratch.png){ width=70% }

We’ll start with the billing application. Find the Go starter workflow and click on customize:

![Select the Go starter workflow](./figures/04-go-starter.png){ width=95% }

### 3.2.1 Billing service

You have to modify the job a bit before it works:

1.  The billing app uses Go version 1.14. So, change the first line to `sem-version go 1.14`.
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

And **uncheck** all the checkboxes under Dependencies. TODO PIC

![No dependencies in the User block](./figures/04-no-dep-user.png){ width=95% }

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

Now click on **run the workflow**. Type “master” in Branch and click on **start**. Choosing the right branch matters because it affects how commits are calculated. We’ll talk about that in a bit.

## 3.3 Setting up change detection

CHANGE DETECTION HERE



Let’s see how `change_in` can help us speed up the pipeline.

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

Next, run the pipeline again. The first thing you’ll notice is that there's a new initialization step. Here, Semaphore is calculating the differences to decide what blocks should run. You can check the log to see what is happening behind the scenes.

Once the workflow is ready, Semaphore will start running all jobs one more time (this happens because we didn’t set `pipeline_file: 'ignore' `). The interesting bit comes later, when we change a file in one of the applications, this is what we get:

![Running all blocks](./figures/04-skip-but-billing.png){ width=40% }

Can you guess which application I changed? Yes, that’s right: it was the billing app. As a result, thanks to `change_in`, the rest of the blocks have been skipped because neither did meet the change conditions.

If we make a change outside any of the monitored folders, then all the blocks are skipped and the pipeline completes in just a few seconds.

![Skipping all blocks](./figures/04-skip-all.png){ width=40% }



![Run the workflow](./figures/04-run-master.png){ width=70% }

Now, what happens if we change a file inside the `/services/ui` folder?

![All blocks running](./figures/04-all-blocks1.png){ width=40% }

Yeah, despite only one of the projects has changed, all the blocks are running. This is… not optimal. For a big monorepo with hundreds of projects, that’s a lot of wasted hours, with added boredom and axiety for software developers. The good news is that this is a perfect fit for trying out change-based execution.






# What is a monorepo? (and Should You Use Them?)

*Monorepos can be a great force for fostering rapid development workflows. In this post, we’ll examine if they are the right fit for you and your company.*

## What is a monorepo?

A *monorepo* is a version-controlled code repository that holds many individual projects. While these projects may be related, they are often logically independent and run by different teams.

Some companies host all their code in a single repository, shared among everyone. Monorepos can reach colossal sizes. Google, for example, is theorized to have the largest code repository ever, which has tens of hundreds of commits per day and exceeds 80 TBs in size. Other companies known to run large monorepos are Microsoft, Facebook, and Twitter.

Monorepos are sometimes called *monolithic repositories*, but they should not be confused with *monolithic architecture*, which is a software development practice for writing centralized applications using a single codebase. An example of this is a Ruby on Rails monolith handling websites, API endpoints, and background jobs.

## Monorepos vs. multirepos

The opposite of the monorepo is *multirepo*, where each project is held on a completely separate, version-controlled software repository. Multirepos come naturally — it’s what we do when starting a new project. After all, who doesn’t like starting fresh?

Going from multi to monorepo is merely a matter of moving all your projects into a single repository.

![Multirepo to Monorepo](./figures/02-multi-to-mono.jpg)

``` bash
$ mkdir monorepo
$ git init
$ mv ~/src/app-android10 ~/src/app-android11 ~/src/app-ios .
$ git add -A
$ git commit -m "My first monorepo"
```

Of course, this is just to get started. The hard work comes when we get into refactoring and consolidation.

Multirepos are not a synonym for *microservices*; one does not need the other. In fact, we’ll later discuss about companies using monorepos and microservices at the same time. A monorepo can host any number of microservices as long as you carefully set up your Continuous Integration and Delivery (CI/CD) [pipeline](https://semaphoreci.com/blog/cicd-pipeline) for deployment.

## Loving monorepos

At first glance, the choice between monorepos and multirepos may not seem like a big deal, but it’s a decision that will deeply influence your company’s development workflow.

Monorepos have the following benefits:

-   **Visibility**: everyone can see everyone else’s code. This property leads to better collaboration and cross-team contributions. A developer in a different team can fix a bug in your code you didn’t even know existed.
-   **Simpler dependency management**: sharing dependencies is trivial. There’s little need for a  package manager as all modules are hosted in the same repository.
-   **Single source of truth**: one version of every dependency means there are not versioning conflicts and no dependency hell.
-   **Consistency**: enforcing code quality standards and a unified style is easier when you have all your codebase in one place.
-   **Shared timeline**: Breaking changes in APIs or shared libraries are exposed immediately, forcing different teams to communicate ahead and join forces. Everyone is invested in keeping up with changes.
-   **Atomic commits**: atomic commits make large-scale refactoring possible. A developer can update several packages or projects at once in a single commit.
-   **Implicit CI**: [continuous integration](https://semaphoreci.com/continuous-integration) is guaranteed as all the code is already integrated into one place.
-   **Unified CI/CD process**: you can use the same [CI/CD](https://semaphoreci.com/cicd) deployment process for every project in the repo.

## Hating monorepos

As monorepos grow, we reach design limits in version control tools, build systems, and continuous integration pipelines. These problems can make a company go the multirepo route:

-   **Bad performance**: monorepos are difficult to scale up. Commands like `git blame` take unreasonably long times, IDEs begin to lag, and testing the whole repo on every change becomes infeasible.
-   **Broken main/master**: a broken master affects everyone working in the monorepo. This can be seen as either disastrous or as a good motivation to keep tests clean and up to date.
-   **Learning curve**: the learning curve for new developers is steeper if the repository spans many tightly-coupled projects.
-   **Large volumes of storage**: monorepos can reach unwieldy volumes of data and commits per day.
-   **Ownership**: maintaining ownership of files is more challenging. Systems like Git or Mercurial don’t feature built-in directory permissions.
-   **Code reviews**: notifications can get very noisy. For instance, GitHub sends notifications them to every developer in the repository.

You may have noticed that most of these problems are technical. In the following sections we’ll learn how companies that stuck to monorepos have solved most of them by investing in tooling, adding integrations, and writing custom solutions.

## It’s not (only) about technology

Choosing a repository strategy is not only a technical matter but also about how people communicate. As [Conway’s Law](https://www.thoughtworks.com/insights/articles/demystifying-conways-law) states, communication is essential for building great products:

> Any organization that designs a system will produce a design whose structure is a copy of the organization’s communication structure. – Melvin E. Conway

While multirepos allow each team to manage their projects independently, they also put up collaboration barriers. In that way, they can act as blinders, making developers focus only on the part they own, forgetting the overall picture.

A monorepo, on the other hand, works as a central hub, a market square where every developer, engineer, tester, and business analyst meet and talk. Monorepos encourage conversations, helping us bring silos down.

## Monorepo culture

Monorepos have been around for a long time. For three decades, FreeBSD has [used CVS and later subversion monorepos](https://docs.freebsd.org/en_US.ISO8859-1/articles/committers-guide/article.html) for development and package distribution.

Many open-source projects have been using monorepos successfully. For instance:

-   [Laravel](https://laravel.com/): a PHP framework for web development.
-   [Symfony](https://symfony.com/): another MVC framework. What’s interesting about this is that they have created read-only repositories for each of the Symfony tools and libraries. This approach is called *split-repo*.
-   [NixOS](https://github.com/NixOS/nixpkgs/): this Linux distribution uses a monorepo for publishing packages.
-   [Babel](https://github.com/babel/babel/blob/master/doc/design/monorepo.md): a popular JavaScript compiler used in web development. A monorepo holds the complete project and all its plug-ins.
-   Also, frontend frameworks like [React](https://github.com/facebook/react/tree/master/packages), [Ember](https://github.com/emberjs/ember.js/tree/master/packages), and [Meteor](https://github.com/meteor/meteor/tree/devel/packages) all use monorepos.

Yet, the real question is if commercial software can benefit from monorepo layouts. Given the pluses and the minuses, let’s hear the experience of a few companies that have tried them.

**Segment, goodbye multirepos**

Alex Noonan tells a tale about saying [goodbye to multirepos](https://segment.com/blog/goodbye-microservices/). Segment.com, the company where she works, offers an event collection and forwarding service. Each of its customers needs to consume data in a special format. Thus, the engineering team initially decided to use a mix of microservices and multirepos.

The strategy worked well — as the customer base grew, they scaled up without problems. But, when the number of forwarding destinations passed the hundred mark, things started to break down. The administrative load of maintaining, testing, and deploying +140 repositories — each with hundreds of increasingly diverging dependencies — was too high.

> “Eventually, the team found themselves unable to make headway, with three full-time engineers spending most of their time just keeping the system alive.”

For Segment the remedy was consolidation. The team migrated all the services and dependencies into a single monorepo. While the transition was successful, it was very taxing as they had to reconcile shared libraries and test everything each time. Still, the end result was reduced complexity and increased maintainability.

> “The proof was in the improved velocity. \[…\] We’ve made more improvements to our libraries in the past 6 months than in all of 2016.”

Many years later, when a panel [asked about her experience with microservices](https://www.infoq.com/articles/microservices-from-trenches-lessons-challenges/), Alex explained the reasons for moving to a monorepo:

> “It didn’t turn out to be as much of an advantage as we thought it was going to be. Our primary motivation for breaking it out was that failing tests were impacting different things. [..] Breaking them out into separate repos only made that worse because now you go in and touch something that hasn't been touched in six months. Those tests are completely broken because you aren't forced to spend time fixing that. One of the only cases where I've seen stuff successfully broken out into separate repos and not services is when we have a chunk of code that is shared among multiple services, and we want to make it a shared library. Other than that, I think we've found even when we've moved to microservices, we still prefer stuff in a mono repo.”

**Airbnb and the monorail**

Jens Vanderhaeghe, infrastructure engineer at Airbnb, also [tells how microservices and monorepos helped them scale out globally](https://www.youtube.com/watch?v=sakGeE4xVZs).

Airbnb’s initial version was called “the monorail.” It was a monolithic Ruby on Rails application. When the company started its exponential growth, the codebase followed suit. At the time, Airbnb ran a novel release policy called *democratic releases*, which meant that any developer can release to production at any time.

The democratic process limits were tested as Airbnb expanded. Merging changes got harder and harder. Jens’ team implemented palliative measures like a merge queue and increased monitoring. These helped for a time, but it wasn’t enough in the long run.

Airbnb engineers fought a valiant fight to keep the monorail up, but eventually, after weeks of debate, they decided to split the application into microservices. And so, they created two monorepos: one for the frontend and one for the backend. Both comprise hundreds of services, the documentation, Terraform and Kubernetes resources for deployment, and all the maintenance tools.


When asked about the high points of a monorepo layout, Jens says:

> “We didn’t want to deal with version dependencies between all of these microservices. \[With monorepo\] you can make a change across two microservices with a single commit [..] We can build all of our tooling around a single repository. The biggest selling point is that you can make changes on multiple microservices at once. We run a script, and we detect which apps in the monorepo are impacted, and these get deployed. Our main benefit is source control.”

**Uber, there and back again**

Aimee Lucido, from Uber, describes the process of going [from monorepo to multirepo and back again](https://www.youtube.com/watch?v=lV8-1S28ycM).

At the time, she was working on the Android client team. They used monorepos from the very beginning. But after five years of active development, the problems of monorepo started to show.

> “We started to get the dreaded IDEs lockdowns. We got to the point where we couldn’t even scroll in Android Studio without the code freezing up.”

The problems didn’t end with the IDE. Slowness also affected Git, and builds dragged on and on. To make matters worse, they frequently experienced broken masters, which prevented them from building anything.

> “The bigger the company gets, the more frequent you’ll experience a broken master.”

When Uber reached midsize level, the team decided to go multirepo. Immediately, their problems began to disappear. Uber engineers loved the fact they could own a part of the code and only be responsible for it.

> “If you only build the maps app, then what you build is faster. It’s lovely.”

But the story doesn’t end there. Again some time passed, and the multirepo strategy began to show its weaknesses. This time it wasn’t simply about technical issues but about how people collaborated. Teams were breaking down into silos, and the overhead of managing thousands of repositories consumed a lot of valuable time.

Each group had its own coding styles, frameworks, and testing practices. Managing dependencies also got harder, and the dependency hell monster reared its ugly head. This made it very hard at the end of the day to integrate everything into a single product.

It was at this point that Uber engineers regrouped and decided to give monorepo one more chance. With a lot more resources and knowing ahead of time the problems they would face, they choose to invest in tooling: they changed IDEs, implemented a merge queue, and used differential builds to speed up deployments.

> “When you get to a big company size, you can invest your resources to make your big company feel like a small company, to make the cons into pros.”

**Pinterest, full-speed to monorepo**

Let’s conclude by examining a company that’s in the middle of a three-year-long migration: Pinterest. Their effort is two-pronged. First, move more than 1300 repositories into only four monorepos. Second, consolidate hundreds of dependencies into a monolithic web application.

Why are they doing it? Well, [Eden JnBaptiste](https://www.youtube.com/watch?v=r5KHQnS6uP8) explains that multirepos made it hard for them to reuse code. It’s the same story: the code was spread too thin, and each team had its own repo, with individual styles and structure. The build process quality standard was highly variable, so building and deploying it was too hard.

Pinterest found that [trunk-based development](https://trunkbaseddevelopment.com/) paired with monorepos helped make a headway. The cornerstone of trunk-based development is using only short-lived branches and merging to the main branch as frequently as possible, reducing the chance of merge conflicts.

> “Having all the code in one repository helped us reduce the feedback loop \[in our build systems\].”

For Pinterest, a monorepo layout provided a consistent development workflow. Automation, simplification, and standardization of release practices allowed them to cut down on boilerplate and let developers focus on writing code.

## Investing in tooling

If we have to take only one lesson from all these stories, it is that proper tooling is key for effective monorepos — building and testing need to be rethought. Instead of rebuilding the complete repo on each update, we can use smart build systems that understand the structure of the projects and work only in the parts that have changed since the last commit.

![Monorepo build systems](./figures/02-build.png)

Most of us don’t have Google’s or Facebook’s resources. What can we do? Fortunately, many of the bigger companies have open-sourced their build systems:

-   [Bazel](https://bazel.build/): released by Google and based partly on their homegrown build system (Blaze). Bazel supports many languages and is capable of building and testing at scale.
-   [Buck](https://buck.build/): Facebook’s open-source fast build system. Supports differential builds on many languages and platforms.
-   [Pants](http://www.pantsbuild.org/): The Pants build system was created in collaboration with Twitter and Foursquare. For the moment, it supports only Python, with more languages on the way.
-   [RushJS](https://rushjs.io/): Microsoft’s scalable monorepo manager for JavaScript.

Monorepos seem to be getting more attention, particularly in JavaScript, as shown by these projects:

-   [Lerna](https://github.com/lerna/lerna): monorepo manager for JavaScript. Integrates with popular frameworks like React, Angular, or Babel.
-   [Yarn Workspaces](https://classic.yarnpkg.com/en/docs/workspaces/): installs and updates dependencies for Node.js in multiple places with a single command.
-   [ultra-runner](https://github.com/folke/ultra-runner): scripts for JavaScripts monorepo management. Plugs in with Yarn, pnpm, and Lerna. Supports parallel building.
-   [Monorepo builder](https://github.com/Symplify/MonorepoBuilder): installs and updates packages across PHP monorepos.

**Scaling Up Repositories**

Source control is another pain point for monorepos. These tools help you scale up repositories:

-   [Virtual Filesystem for Git](https://vfsforgit.org/) (VFS): adds streaming support for Git. VFS downloads objects from Git repositories as needed. This project was originally created to manage the Windows codebase (which is the largest Git repository). Works only in Windows, but MacOS support has been announced.
-   [Large File Storage](https://git-lfs.github.com/): an open-source extension for Git that adds better support for large files. Once installed, you can track any type of file and seamlessly upload them into cloud storage, freeing up your repository and making pushing and pulling much faster.
-   [Mercurial](https://www.mercurial-scm.org/): an alternative to Git, Mercurial is a distributed version control tool that focuses on speed. Facebook uses Mercurial and has contributed many [speed-enhancing patches](https://engineering.fb.com/2014/01/07/core-data/scaling-mercurial-at-facebook/) over the years.
-   [Git CODEOWNERS](https://help.github.com/articles/about-codeowners/): lets you define which team owns subdirectories in the repository. Code owners are automatically requested to review when someone opens a pull request or pushes into a protected branch. This feature is supported by GitHub and GitLab.

**Best Practices for Monorepo Management**

Based on the collection of monorepo stories, we can define a minimum set of best practices:

-   Define a unified directory organization for easy discovery.
-   Maintain branch hygiene. Keep branches small, consider adopting trunk-based development practices.
-   Use pinned dependencies for every project. Upgrade dependencies all at once, force every project to keep up with the dependencies. Reserve exceptions for truly exceptional cases.
-   If you’re using Git, learn how to use [shallow clone](https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/) and [filter-branch](https://git-scm.com/docs/git-filter-branch) to handle large-volume repositories.
-   Pick a smart build system like Bazel or Buck to speed building and testing.
-   Use CODEOWERS when you need to restrict access to certain projects.
-   Use a cloud CI/CD platform like [Semaphore](https://semaphoreci.com) to test and deploy your applications at any scale.

## Should you use monorepos?

It depends. There are no straight answers that fit every use case. Some companies may choose monorepo for a while and then decide they need to switch to multirepos or vice-versa, while others may choose a mix. When in doubt, consider that moving from monorepo to multirepo is usually easier than the inverse.

But never lose sight that, in the end, it’s not about technology but about work culture and communication. So, decide based on the way you want to work.

Read next: [Learn how to run monorepos at scale in Semaphore CI/CD](https://semaphoreci.com/product/whats-new-2021).


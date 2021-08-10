\newpage

# 1 Introduction to Monorepos

Monorepos can be a great force for fostering rapid development workflows. But, are they the right fit for you, your team, and your company?

## 1.1 What Is a Monorepo?

Not everyone agrees on a single definition for *monorepo*. Some may only accept the term when it applies to companies hosting *all* their code in a single repository. Google is the most famous example of this; their monorepo is theorized to be the largest code repository ever around, which has thousands of commits per day and exceeds 80 TBs in size.

More relaxed definitions will say that *a monorepo is a version-controlled code repository holding a number of independently-deployable projects*. While these projects may be related, they are often separate, logically-independent, and run by different teams. For instance, Airbnb has two monorepos: one for the frontend code and one for the backend code. In this way, a company or organization can utilize multiple monorepos.

Monorepos are sometimes also called *monolithic repositories*, but they should not be confused with *monolithic architecture*, a software development practice for writing centralized applications using a single codebase. To give one example to these kinds of architectures, think of a Ruby on Rails application handling websites, API endpoints, and background jobs all at once.

## 1.2 Monorepos vs. Multirepos

The opposite of the monorepo is a *multirepo*, or simply *repos*, where each project is held on a completely separate, version-controlled software repository. Multirepos come naturally — it’s what we do when starting a new project. After all, who doesn’t like starting fresh?

Moving from multi to monorepo is merely a matter of moving all your projects into a single repository.

``` bash
$ mkdir monorepo
$ git init
$ mv ~/src/app-android10 ~/src/app-android11 ~/src/app-ios .
$ git add -A
$ git commit -m "My first monorepo"
```

![Multirepo to Monorepo](./figures/02-multi-to-mono.png){ width=65% }

Of course, this is just to get started. The hard work comes later, when we get into refactoring and consolidation. To enjoy the full benefits of a monorepo, all shareable code should be moved outside of each project folder and into a common location.

Multirepos are not a synonym for *microservices*. In fact, having one does not require using the other. Later, we'll discuss companies using monorepos *with* microservices. A monorepo can host any number of microservices as long as you carefully set up your Continuous Integration and Delivery [(CI/CD) pipeline](https://semaphoreci.com/blog/cicd-pipeline)[^pipeline] for deployment.

[^pipeline]: CI/CD Pipeline, A Gentle Introduction - _<https://semaphoreci.com/blog/cicd-pipeline>_

## 1.3 What Monorepos Bring to the Table

At first glance, the choice between monorepos and multirepos might not seem like a big deal. On closer inspection, however, it’s a decision that deeply influences how you and your team interact.

Monorepos have the following benefits:

-   **Visibility**: everyone can see everyone else’s code, leading to better collaboration and cross-team contributions. Any developer can fix a bug in your code before you even notice it.
-   **Simpler dependency management**: sharing dependencies is trivial. There’s little need for a complex package manager setups as all modules are hosted in the same repository.
-   **Single source of truth**: one version of every dependency means there are no versioning conflicts and no dependency hell.
-   **Consistency**: enforcing code quality standards and a unified style is straightforward when you have your entire codebase in one place.
-   **Shared timeline**: breaking changes in APIs or shared libraries are immediately exposed, forcing different teams to communicate and join forces. Monorepos keep everyone invested in keeping up with changes.
-   **Atomic commits**: atomic commits make large-scale refactoring possible. In theory, a developer can update several packages or projects at once in a single commit. In practice, these types of changes are usually rolled out in stages, not all at once.
-   **Implicit CI**: continuous integration is guaranteed as all the code is already integrated into one place.
-   **Unified CI/CD process**: you can use the same CI/CD deployment process for every project in the repo.

## 1.4 Technical Challenges

As monorepos grow, we reach design limits in version control tools, build, systems, and continuous integration solutions. These problems can make a company go the multirepo route:

-   **Bad performance**: monorepos can be difficult to scale up. Commands like `git blame` take unreasonably long, IDEs begin to lag, and testing the whole repo for every change becomes infeasible.
-   **Broken main/master**: a broken master affects everyone working in the monorepo. This can be seen as either disastrous or as a good motivation to keep tests clean and up to date.
-   **Learning curve**: the learning curve for new developers is steeper if the repository spans many tightly-coupled projects. Keep in mind, however, that the same can be the case with multi-repos.
-   **Large volumes of storage**: monorepos can reach unwieldy sizes and very large quantities of commits per day.
-   **Ownership**: maintaining ownership of files is more challenging. Systems like Git or Mercurial don’t feature built-in directory-level permissions.
-   **Code reviews**: notifications can get very noisy. For instance, GitHub sends notifications about PRs to every developer in the repository.

You may have noticed that these problems are mostly technical. Some of them can be mitigated by adopting the *trunk-based development* model, which encourages engineers to collaborate in a single branch — the trunk — and proposes limiting the lifespan of topic branches to a minimum.

## 1.5 It’s Not (Only) about Technology

Choosing a repository strategy is not only a technical matter but also about how people communicate. As stated by Conway’s Law, communication is essential for building great products:

> Any organization that designs a system will produce a design whose structure is a copy of the organization’s communication structure.
>
> — Melvin E. Conway

While multirepos allow each team to manage their projects independently, they also put up communications barriers. In that way, they can act as blinders, making developers focus only on the part they own, forgetting the overall picture.

A monorepo, on the other hand, works as a central hub, a market square of sorts where developers, engineers, testers, and business analysts meet and talk. Monorepos encourage conversations while helping bring silos down.

## 1.6 Notable Monorepo Adopters

Open-source projects, by their nature, have more freedom to experiment and feel greater pressure to self-organize. For three decades, FreeBSD has [used CVS and later subversion monorepos](https://docs.freebsd.org/en_US.ISO8859-1/articles/committers-guide/article.html) for development and package distribution. Other notable projects with monorepo support or that are monorepos themselves are [Babel](https://github.com/babel/babel/blob/master/doc/design/monorepo.md), Google's [Angular](https://angular.io/guide/file-structure), Facebook's [React](https://github.com/facebook/react/tree/master/packages) and [Jest](https://jestjs.io/docs/next/configuration), and [Gatsby](https://github.com/gatsbyjs/gatsby/tree/master/packages).

Comercial companies have also posted about their journey towards monorepos. Besides the big ones like Google, Facebook, or Twitter, we find some interesting cases such as:

- [Segment.com](https://segment.com/blog/goodbye-microservices/)[^segment]: a company offering an event collection and forwarding service. Initially, they used one repository per customer. As the number of customers increased, they moved their 140 repositories into a single one. They migrated all the services and dependencies into their monorepo. While the transition was successful, it was very taxing as they had to reconcile shared libraries and test everything each time. Still, the end result was reduced complexity and increased maintainability.
- [Airbnb](https://www.youtube.com/watch?v=sakGeE4xVZs)[^airbnb]: initially ran on Ruby on Rails. Their "monorail" accompanied the company's exponential growth, until it didn't. Eventually, it was obvious that the rate of changes and number of commits was too much for a single repository. After some debate, they chose to split development into two monorepos: one for the frontend and one for the backend. Both comprise hundreds of services, the documentation, Terraform and Kubernetes resources for deployment, and all the maintenance tools.
- [Pinterest](https://www.youtube.com/watch?v=r5KHQnS6uP8)[^pinterest]: has an ongoing three-year-long migration. The plan is to move more than 1300 repositories into only four monorepos and then consolidate hundreds of dependencies into a monolithic web application. The objective is to get a more uniform build process and higher quality standard. Automation, simplification, and standardization of release practices allowed them to cut down on boilerplate and let developers focus on writing code.
- [Uber](https://eng.uber.com/go-monorepo-bazel/)[^uber]: their build system used to be a combination of the Golang toolchain and Make. As they moved their mobile development to the monorepo and the number of files reached the 70 thousand mark, Make no longer fulfilled their needs. They elected to adopt Bazel, an offshoot of Google's build system, designed for scalability and featuring incremental builds, to which they ended contributing several patches and improvements. According to Uber, their monorepo is likely one of the largest Go repositories running on Bazel.

[^segment]: Goodbye Microservices - _<https://segment.com/blog/goodbye-microservices/>_

[^airbnb]: From Monorail to Monorepo, Airbnb’s journey into Microservices - _<https://www.youtube.com/watch?v=sakGeE4xVZs>_

[^pinterest]: Pinterest’s journey to a Bazel monorepo - _<https://www.youtube.com/watch?v=r5KHQnS6uP8>_

[^uber]: Building Uber’s Go Monorepo with Bazel - _<https://eng.uber.com/go-monorepo-bazel/>_

## 1.7 Investing in Tooling

If we have to take only one lesson from all these stories, it is that proper tooling is key for effective monorepos. Building and testing need to be rethought: instead of rebuilding the entire repo on each update, we can use smart build systems that understand the structure of the projects and work only on the parts that change.

On a high level, a smart build system would need to:

1. Determine which files changed due to commits since the last build.
2. Find all the projects and their dependencies affected by the changes.
3. Build these projects, ideally using some form of caching.
4. Run tests based on affected code.
5. Deploy the projects that have changed into staging or production.

Most of us, however, don’t have Airbnb's resources. So, what can we do? Fortunately, many larger companies have open-sourced their build systems:

-   [Bazel](https://bazel.build/): released by Google and based partly on their homegrown build system (Blaze). Bazel supports many languages and is capable of building and testing at scale.
-   [Buck](https://buck.build/): Facebook’s open-source fast build system. Supports differential builds on many languages and platforms.
-   [Pants](http://www.pantsbuild.org/): The Pants build system was created in collaboration with Twitter and Foursquare. For the moment, it supports only Python, but more languages are on the way.
-   [RushJS](https://rushjs.io/): Microsoft’s scalable monorepo manager for JavaScript.

Monorepos seem to be getting more attention, particularly in JavaScript, as shown by these projects:

-   [Lerna](https://github.com/lerna/lerna): monorepo manager for JavaScript. Integrates with popular frameworks like React, Angular, or Babel.
-   [Yarn Workspaces](https://classic.yarnpkg.com/en/docs/workspaces/): installs and updates dependencies for Node.js in multiple places with a single command.
-   [ultra-runner](https://github.com/folke/ultra-runner): scripts for JavaScripts monorepo management. Works with Yarn, pnpm, and Lerna. Supports parallel building.
-   [Monorepo builder](https://github.com/Symplify/MonorepoBuilder): installs and updates packages across PHP monorepos.
-   [NPM](https://docs.npmjs.com): since version 7, has [support for workspace](https://docs.npmjs.com/cli/v7/using-npm/workspaces).

## 1.8 Scaling up Repositories

Source control is another sticking point for monorepos. These tools can help you scale up repositories:

-   [Virtual Filesystem for Git](https://vfsforgit.org/) (VFS): adds streaming support for Git. VFS downloads objects from Git repositories as needed. This project was originally created to manage the Windows codebase (which is the largest Git repository). Works only in Windows, but MacOS support has been announced.
-   [Large File Storage](https://git-lfs.github.com/): an open-source extension for Git that adds better support for large files. Once installed, you can track any type of file and seamlessly upload it into cloud storage, freeing up your repository and making pushing and pulling much faster.
-   [Mercurial](https://www.mercurial-scm.org/): an alternative to Git, Mercurial is a distributed version control tool that focuses on speed. Facebook uses Mercurial and has contributed many [speed-enhancing patches](https://engineering.fb.com/2014/01/07/core-data/scaling-mercurial-at-facebook/) over the years.
-    [CODEOWNERS](https://help.github.com/articles/about-codeowners/): lets you define which team owns subdirectories in the repository. Code owners are automatically requested to review when someone opens a pull request or pushes into a protected branch. This feature is supported by GitHub and GitLab.

## 1.9 Best Practices for Monorepo Management

Based on what we have learned about monorepos, we can define a minimum set of best practices:

-   Define a unified directory organization for easy discovery.
-   Maintain branch hygiene. Keep branches small, consider adopting trunk-based development practices.
-   Use pinned dependencies for every project. Upgrade dependencies all at once, force every project to keep up with the dependencies. Reserve exceptions for truly exceptional cases.
-   If you’re using Git, learn how to use [shallow clone](https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/)[^shallow-clone] and [filter-branch](https://git-scm.com/docs/git-filter-branch)[^filter-branch] to handle large-volume repositories.
-   Pick a smart build system like Bazel or Buck to speed building and testing.
-   Use CODEOWNERS when you need to restrict access to certain projects.
-   Use a cloud CI/CD platform like [Semaphore](https://semaphoreci.com) to test and deploy your applications at any scale.

[^shallow-clone]: Get up to speed with shallow clone - _<https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/>_

[^filter-branch]: git-filter-branch reference page - _<https://git-scm.com/docs/git-filter-branch>_

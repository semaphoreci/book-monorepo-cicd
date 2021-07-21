\newpage

© 2021 Rendered Text. All rights reserved.

This work is licensed under Creative Commmons
Attribution-NonCommercial-NoDerivatives 4.0 International.
To view a copy of this license, visit
<https://creativecommons.org/licenses/by-nc-nd/4.0>

This book is open source: TODO: link
<https://github.com/semaphoreci/book-cicd-docker-kubernetes>

Published on the Semaphore website:
[https://semaphoreci.com](https://semaphoreci.com/?utm_source=ebook&utm_medium=pdf&utm_campaign=cicd-docker-kubernetes-semaphore)

$MONTHYEAR: First edition v1.0 (revision $REVISION)

\newpage

Share this book:

> _ I’ve just started reading “CI/CD for Monorepos,” a free ebook by @semaphoreci: TODO:link https://bit.ly/3bJELLQ ([Tweet this!](TODO: link https://ctt.ac/c5Ub9))_

\newpage

## Preface

A monorepo is a new name for an old idea: place a bunch of software projects in the same repository. This approach has many benefits: increase visibility and easy code sharing, greater consistency and common coding practices.

Companies like Google, Facebook, Twitter, and Airbnb have been using monorepos for many years. Today, we see a growing number of smaller teams choosing to work this way, adopting monorepos as their way of coding. The jury is still out, but the tide seems to be turning. 

Why the change now? As monorepos grow in size,  number of limiting factors come into play. Greatest of them all is scaling. Most companies don't have the resources to solve the technical challenges around monorepos. Companies like Google, Facebook, Twitter open-sourced their innovative build systems, tooling matured, and new solutions were developed. Monorepos are getting a lot of traction. Luckily, tooling is evolving, a lot of monorepo-first companies have open-sourced they monorepo solutions. The barriers to adopting monorepo are falling down. 

At Semaphore, we have been using monorepos internally for a long time. We know how cool they can be and how painful they can get to set up. Because we want every engineering team to enjoy a great experience, [we’ve released monorepo features](https://semaphoreci.com/blog/monorepo-support-available). Bringing Semaphore to be the first CI/CD platform with such support.

Semaphore steps up the monorepo game with:

- **Initialization step** – Runs at the start of each monorepo pipeline and compiles the workflow, ensuring that  misconfigurations are detected before any job starts.
- **UI indicator** – A new UI element shows the initialization log, making troubleshooting fast and easy. 
- **Exclude parameter** – A new option in  `*change_in*` adds the ability to define which folders or files to skip. 
- **Glob pattern support** – `change_in` conditions have been further extended to allow the use of wildcards.
- **Improved stability** – All compilation errors coming from edge cases were eliminated, making these features more reliable. 

\newpage

## Who Is This Book For, and What Does It Cover?

This book is intended for engineering teams, developers, and companies interested in trying out the monorepo way of software development. Teams already using monorepos in any form should also benefit from the speed-optimizing techniques laid out here.

By showing what it takes to build a monorepo-first CI/CD pipeline, how to save money, time, and speed up software development cycles, we hope that CTOs and other people in charge of delivering software projects will gain some insight into deciding if monorepos are the way forward for their companies and teams.

Chapter 1, “What is a Monorepo,” introduces the basics and relates stories about other companies that have successfully migrated to a monorepo. This chapter will help you decide if monorepo is the right way for you.

Chapter 2, “Continuous Integration,” explains what you need to know about setting up a CI pipeline that builds and tests only the code that changes.

Chapter 3, “Continuous Deployment,” describes how to expand the CI pipeline with continuous deployments. We’ll learn how to take a working example and deploy it on a real cloud service. At the end of the book, you’ll have a functional microservice application build, tested, and deployed from a monorepo.

## How to Contact Us

We would very much love to hear your feedback after reading this book. What did you like and learn? What could be improved? Is there something we could explain further?

A benefit of publishing an ebook is that we can continuously improve it. And that’s exactly what we intend to do based on your feedback.

You can send us feedback by sending an email to <learn@semaphoreci.com>.

Find us on Twitter: <https://twitter.com/semaphoreci>

Find us on Facebook: <https://facebook.com/SemaphoreCI>

Find us on LinkedIn: <https://www.linkedin.com/company/rendered-text>

## About the Author

**Pablo Tomas Fernandez Zavalia** is an electronic engineer and writer. He started developing for the City of Buenos Aires City Hall (buenosaires.gob.ar). After graduating, he joined British Telecom as head of the Web Services department in Argentina. He then worked on IBM as a database administrator, where he also did tutoring, DevOps, and cloud migrations. In his free time, he enjoys writing, sailing, and board games. Follow Tomas on Twitter at [\@tomfernblog](https://twitter.com/tomfernblog).

## Acknowledgments

I want to thank Marko Anastasov for the opportunity to write this book. In addition, all the Semaphore team for their incredible work. Without their help, this book could never have existed.


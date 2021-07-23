# 4. Change-based delivery

### 4.1 Hello world delivery

We can also use `change_in` on [auto promotions](https://docs.semaphoreci.com/guided-tour/deploying-with-promotions/), which let us automatically start additional pipelines on certain conditions.

To create a new pipeline, open the workflow editor once more and click on **Add First Promotion**:

![Adding a promotion](./figures/05-add-promotion.png){ width=95% }

Check **Enable automatic promotion**. You should see an example snippet you can use as a starting point.



TODO: change deployment to generic

![Example change\_in condition](./figures/05-autopromotion-example.png){ width=90% }

You can combine `change_in` and `branch = 'master' AND result = 'passed'` to start the pipeline when all jobs pass on the default branch.

``` json
change_in('/services/billing/') and branch = 'master' AND result = 'passed'
```

![Auto promotion conditions](./figures/05-promotion-condition.png){ width=90% }

Once done, run the workflow to save the changes. From now on, when you make a change to the billing app, the new pipeline will start automatically if all tests pass on `master`.

![Pipeline auto promoted](./figures/05-promotion-done.png){ width=95% }

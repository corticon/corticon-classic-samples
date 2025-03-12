### Halloween Candy Trading Rules with Corticon

See how you could use Corticon to build a custom Halloween candy distribution strategy to assess for timeline, parental checks and allergen reassignment.

On October 31, the U.S. celebrates the Halloween holiday, where children dress in costumes and collect candy during an evening ritual called “Trick or Treat.”

A conscientious parent wants to establish some rules to govern her children’s candy consumption in the aftermath of Halloween. These “screening” rules include:

*   All unpackaged or unwrapped items must be discarded. This includes fruit, baked goods or candy with damaged wrapping. If fruit, then the parent will replace the item with a new, fresh (and known safe) item of the same kind.
*   Because little Jimmy has a nut allergy, all items containing nuts must be given to his big sister, Sarah.
*   For every item containing nuts given to Sarah by Jimmy, Sarah will repay him with an item not containing nuts.
*   Finally, the parent would like all of this nonsense to be over with as quickly as possible. How many items, on average, must she distribute to each child per day so that all candy is gone within 30 days? Alternatively, if decides the maximum daily allotment per child is 3 pieces, how long will each child’s supply last? The preferred distribution strategy will be the option which gets the whole thing over with as soon as possible.

Like many decisions modeled using Progress [Corticon Studio](https://www.progress.com/corticon), this one can be approached as a series of steps. We’ll model these steps as individual rulesheets to help us organize our thinking, making it easier to change the rules later.

![diagram of a trade: discard and replace - trade - repay - allocate](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_trade-diagram.png?sfvrsn=8dd12e98_2)

Here are the basics steps we’ll model:

1.  **Discard & Replace**: Applying the first rule, we’ll inspect every item and mark or “tag” those which need to replaced or discarded.
2.  **Trade**: Applying the second rule, Sarah gets all of Jimmy’s items containing nuts.
3.  **Repay**: Applying the third rule, Sarah “pays back” Jimmy with an appropriate item (not containing nuts) for each item he gave her.
4.  **Allocate**: Applying the last rule, we’ll calculate which distribution strategy the parent should choose.

Of course, there are many ways to approach and solve this problem. We prefer those that are clear and organized.

A sample [Vocabulary](https://docs.progress.com/bundle/corticon-basic-guided-journey/page/What-is-a-Vocabulary.html) containing the terms needed to model the rules is shown below. Child and Candy entities are related by an association with one-to-many cardinality, enabling any Child to have a collection of Candy, large or small. A piece of Candy has attributes which indicate its characteristics; for example, does it contain nuts? Is it properly packaged? Etc.

An important assumption is that someone (likely the child’s guardian) will classify each piece of candy using several of these attribute values so that the rules we build have data to work with. Boolean attributes, such as discard and replace, will have values derived by the rules themselves.

The attribute `candyOwed` functions as a “holder” or “counter” value, enabling us to keep track of how many pieces of candy change hands. Because its value is only used internally in the rules, we’ve made it a **transient** attribute.

![Vocabulary: Candy - discard, hasNuts, inProperPackage, isFruit, name, replace; Child - candyCount, candyOwed, daysAtThreePieces, name, piecesForThirtyDays, candy](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_vocabulary.png?sfvrsn=757a9c4e_2)

The first rulesheet, named “discard\_and\_replace” examines every piece of candy (notice the root-level **Candy**, which means *all* candy) and identifies those which must be discarded or replaced. The rulesheet is complete and unambiguous, meaning every piece of candy will receive one, and only one, value for discard and replace.

[![discard and replace rulesheet](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_discard-and-replace-rulesheet.png?sfvrsn=f3a7562d_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_discard-and-replace-rulesheet.png?sfvrsn=f3a7562d_2)

The second rulesheet, named “trade,” acts on those pieces of Jimmy’s candy that were identified (by the parent) as having nuts. When candy containing nuts is found in Jimmy’s [collection](https://docs.progress.com/bundle/corticon-js-rule-modeling/page/How-to-visualize-collections.html), the *Actions* add the item to Sarah’s collection of candy, remove the item from Jimmy’s collection, and increment Jimmy’s `candyOwed` tally by 1.

[![trade rulesheet](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_trade-rulesheet.png?sfvrsn=c73559a6_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_trade-rulesheet.png?sfvrsn=c73559a6_2)

Next it’s payback time. For each item Jimmy gave to Sarah because it had nuts, Sarah needs to give one back. But not just any item will do. Sarah can’t repay Jimmy with items that are due to be discarded or replaced—that wouldn’t be fair. Nor can she repay with items containing nuts—that would defeat the whole purpose of the trade.

In the third rulesheet, named “repay,” one rule takes all of these requirements into account. When an item meeting all Conditions is found in Sarah’s candy collection, the Actions add it to Jimmy’s collection, remove it from Sarah’s and decrement Jimmy’s `candyOwed` tally.

[![repay rulesheet](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_repay-rulesheet.png?sfvrsn=72da9b7e_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_repay-rulesheet.png?sfvrsn=72da9b7e_2)

This is very similar to the trade rulesheet, with one important exception. Let’s assume that Sarah has 5 items in her candy collection which satisfy Condition rows a, b and c. But let’s also assume that Sarah only owes Jimmy 2 items as repayment. How can we stop the evaluation of Sarah’s candy (and its reassignment) after 2 pieces have been repaid to Jimmy? This is tricky, as the default way Corticon evaluates elements in a collection is to evaluate each element satisfying the rule’s scope independently.

In other words, the examination of row b (`SarahsCandy.discard`) by the Conditions is unaffected by the examination of row c (SarahsCandy.replace), or any other item. That means the mere presence of Condition row d (Jimmy.candyOwed > 0) is no guarantee that rule execution will stop once Jimmy has been repaid in full. We need something else to accomplish this goal.

A rule that is not action-only (not in column zero) can be set to [**use conditions as processing thresholds**](https://docs.progress.com/bundle/corticon-rule-modeling-63/page/How-to-use-conditions-as-a-processing-threshold.html). This configuration, enabled by selecting it from the rulesheet with the applicable rule column selected, instructs Corticon to reevaluate all Conditions *each time* a piece of candy is examined. As a result, the strict independence between rows b and c disappears.

[![use conditions as processing thresholds](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_use-conditions-as-processing-thresholds.png?sfvrsn=a245aacd_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_use-conditions-as-processing-thresholds.png?sfvrsn=a245aacd_2)

Once selected, the column header number becomes **bold**, as shown in the screenshot below.

![column shows 1 in bold](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_bold-column-header.png?sfvrsn=58ec747b_2)

When the `candyOwed` tally is down to zero (meaning Jimmy has been fully repaid), the rule execution stops.

Once all candy has been checked, discarded, replaced and traded, we need to choose the right strategy so that all this candy disappears as quickly as possible.

The screenshot below shows two nonconditional rules which calculate two key attribute values needed to select a strategy. Each equation counts the pieces of candy in each child’s collection using the `–> size` operator. Then a Condition/Action rule compares the two options and recommends the final allocation strategy.

[![two nonconditional rules to calculate fastest distribution strategy](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_distribution-strategy.png?sfvrsn=45f64c61_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_distribution-strategy.png?sfvrsn=45f64c61_2)

With all of the steps completed, the parent can now work with candy collections of any size. In the [downloadable](https://github.com/corticon/corticon-classic-samples/tree/main/Halloween%20Candy%20Trading) rule project, you’ll see three test sheets pre-configured. Here we have the results of the middle-sized candy haul:

[![rule message log](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_rule-message-log.png?sfvrsn=d3a85f64_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_rule-message-log.png?sfvrsn=d3a85f64_2)

Running the rule test with the [trace data view](https://docs.progress.com/bundle/corticon-rule-modeling/page/Trace-rule-execution.html), we can see how Corticon has incremented the traded candy values. In case Jimmy and Sarah say the trades were unfair, the trace data log provides us with the precise order and nature of the changes made throughout the four rule sheets in the ruleflow:

[![trace data](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_trace-data.png?sfvrsn=2280a300_2)](https://d117h1jjiq768j.cloudfront.net/images/default-source/blogs/2024/10-24/corticon-halloween_trace-data.png?sfvrsn=2280a300_2)
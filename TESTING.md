###Tesing Failover

There are multiple layers. When using a shield:
1. MISS, MISS: nothing at the edge and the shield also misses
2. MISS, HIT: nothing at the edge but the shield serves state content. Interesting... shield will not serve stale content as a HIT

... presumably a cache will pick up stale content from the shield too?

Will our `if(stale.exists)` clauses execute on the edge or the shield? Both if we enter vcl_fetch.
* fetch will at some point run on the shield
* 503's from the `origin`: 
  * shield should be fne serving stale content here
  * but if the edge is seeing a lot of 503's from the shield node will it drop connecting to it?

#Testing orthagonals

1. Origin is up or down
1. Shield has stale data for the origin within stale_on_error
1. Shield has stale data for the origin within stale_while_revalidate
1. Edge has stale data for the origin within stale_on_error
1. Edge has stale data for the origin within stale_while_revalidate
1. Edge considers shield as a downed backend
1. Shield considers origin as a downed backend

#Test 1:

1. flush edge and shield
1. Set origin to up
1. warm cache (1 hit while using shield should suffice)
1. Set origin to down
1. immediately: check we get a hit:
  * Expected stale while revalidate serves content
  * Then requests from shield:
    * Shield enters vcl_fetch and then serves stale (from stale-while-revalidate or from stale-on-error?)
  * Edge stores stale content as revalidated
1. After stale-while-revalidate time expires: check we get a hit
  * Edge gets request which will MISS at the edge and proceed to the shield
    * shield contacts origin which fails
    * shield serves stale-on-error
    * edge stores and serves (stale-while-revalidate timer reset?)

# Basic High Level Test Plan

1. Warm cache - which with shield should mean one request
  * Use a unique request from one edge node only
2. Take down origin
3. Test we get results both immediately but also after the stale-while-revalidate time has expired
  * Also test from multiple edge nodes


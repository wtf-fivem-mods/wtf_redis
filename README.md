# wtf_redis
Redis client for FiveM

| WARNING: Work in progress! |
| --- |


## Goals

- **Client side API**
  - API doesn't require messaging back and forth between your own client and server scripts
  - Centralized client/server messaging means you can just write your persistence layer along side your client interactions
- **Flexible**
  - Redis is inherently more flexible than MySQL in offering a "shared-heap"
  - Persistence types are analogous to local data structures
  - No schemas required

# mongo-populate

> Populate MongoDB with dummy collections for testing

# Elevator pitch

`mongo-populate` will read JSON documents from disk, and use them to quickly populate a MongoDB database. You can use it to bootstrap a local environment, or to initialise data required for functional tests.

# Data sets

The fake data is organised in "datasets", which represent a whole set of consistent data. They are just folders on disk, containing both files and folders:

- Files will be loaded as an entire collection. They need to export an array of documents
- Folders are expected to contain one file per document, each exporting a single object.

For example:

```
dataset1
   |___ users.coffee
   |___ history.coffee
   |___ products
            |___ phone.coffee
            |___ guitar.coffee   
```

# Configuration

The config file has 2 main sections.
(see the `examples` folder for an config file you can copy).

- The data sets that can be loaded.
   These are just paths to a folder containing all the collections.

```
    datasets:
        bootstrap: "#{__dirname}/dataset1"
        functests: "#{__dirname}/dataset2"
```

- The environments they can be loaded into.
   For each environment, you must specify which collections from the datasets will be loaded. For example, maybe you *never* want to load users into `dev`.

```    
    envs:
        local:
            database: (user, pass) -> 'mongodb://localhost:27017/mystore'
            collections: ['users', 'products', 'history']
        dev:
            database: (user, pass) -> "mongodb://#{user}:#{password}@alex.mongohq.com:10023/mystore"
            collections: ['products']
```

# Let's go

You can call populate in 2 ways:

- passing the exact dataset and target

```
options =
	dataset: 'bootstrap'
	env: 'local'
	username: null
	password: null

populate(config).load options, finish
```

- in interactive mode, where it will prompt you for all required values

```
populate(config).interactive finish
```

A sample callback would be:

```
finish = (err, res) ->
    if err
        console.log err
        process.exit 1
    else
        console.log res
        process.exit 0
```

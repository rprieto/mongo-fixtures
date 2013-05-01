module.exports =
    
    datasets:
        set1: "#{__dirname}/set1"
    
    envs:
        local:
            database: (user, pass) -> 'mongodb://localhost:27017/mystore'
            collections: ['users', 'products', 'history']
        dev:
            database: (user, pass) -> "mongodb://#{user}:#{password}@alex.mongohq.com:10023/mystore"
            collections: ['products']

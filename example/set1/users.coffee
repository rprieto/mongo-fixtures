ObjectID = require('mongodb').ObjectID

module.exports = [
    {
        _id: ObjectID('ffffffffffffffb000000001')
        name: 'John Smith'
        address:
            street: '120 Pitt St'
            city: 'Sydney'
            country: 'Australia'
    }
    {
        _id: ObjectID('ffffffffffffffb000000002')
        name: 'Jane Doe'
        address:
            street: '3 rue Pasteur'
            city: 'Paris'
            country: 'France'
    }
]

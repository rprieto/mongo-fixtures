ObjectID = require('mongodb').ObjectID

module.exports = [
    {
        user: ObjectID('ffffffffffffffb000000001'),
        purchase: ObjectID('ffffffffffffffa000000001'),
        date: new Date('28 Mar 2013')
    }
    {
        user: ObjectID('ffffffffffffffb000000001'),
        purchase: ObjectID('ffffffffffffffa000000002'),
        date: new Date('16 Jan 2013')
    }
    {
        user: ObjectID('ffffffffffffffb000000002'),
        purchase: ObjectID('ffffffffffffffa000000002'),
        date: new Date('04 Apr 2013')
    }
]

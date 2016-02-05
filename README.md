A bunch of helper controller for use with the CFWheels DBMigrate plugin.

To get this up and running, You'll need to install the CFWheels DBMigrate Plugin, the `/models/DBMigrateVersion.cfc` model file and the `/controllers/DBMigrate.cfc` controller from https://github.com/chapmandu/cfwheels-dbmigrate-plugin-tools.

Once these files are in place, you can call the following URLs and see the JSON they return:

http://yoursite/index.cfm?controller=dbmigrate&action=ping
```
{
db: "okay"
}
```

http://yoursite/index.cfm?controller=dbmigrate&action=migrations
```
{
totalMigrationCount: 4,
isOrdered: true,
latest: "20160205201245",
versions: [
{
version: 20140527111730,
cfc: "20140527111730_create_tables",
migrated: true,
details: "create tables"
},
{
version: 20160205201146,
cfc: "20160205201146_insert_lookup_rows",
migrated: false,
details: "insert lookup rows"
},
{
version: 20160205201233,
cfc: "20160205201233_add_plain_text_password_field_to_users_table",
migrated: false,
details: "add plain text password field to users table"
},
{
version: 20160205201245,
cfc: "20160205201245_create_credit_card_number_columns",
migrated: false,
details: "create credit card number columns"
}
],
current: 20140527111730,
migratedCount: 1,
notMigratedCount: 3,
isMigrated: false
}
```

http://yoursite/index.cfm?controller=dbmigrate&action=current
```
{
current: 20140527111730
}
```

http://yoursite/index.cfm?controller=dbmigrate&action=latest
```
{
latest: 20160205201245
}
```

http://yoursite/index.cfm?controller=dbmigrate&action=ismigrated
```
{
ismigrated: false
}
```

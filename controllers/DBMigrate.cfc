component extends="Controller" {

	public void function init() {
		super.init();
		filters("_hideDebug");
	}

	/*** FILTERS ***/

	/**
	 * Hides debug info
	 */
	private any function _hideDebug() {
		setting showdebugoutput="no";
	}

	/*** PUBLIC ***/

	/**
	 * Renders a JSON packet containing a bunch of useful info about your db migration status
	 */
	public string function migrations() {
		var loc = {};

		loc.available = $$dbmigrate().getAvailableMigrations();
		loc.migratedQuery = model("DBMigrateVersion").findAll(distinct=true, where="version > 0", order="version");
		loc.migrated = ValueList(loc.migratedQuery.version);
		loc.migratedCount = loc.migratedQuery.recordCount;
		loc.notMigratedCount = loc.available.Len() - loc.migratedQuery.recordCount;

		loc.returnValue = {};
		loc.returnValue["current"] = $$getCurrentMigration();
		loc.returnValue["latest"] = $$getLatestAvailableMigration();
		loc.returnValue["isMigrated"] = $$getCurrentMigration() eq $$getLatestAvailableMigration() ? true : false;
		loc.returnValue["totalMigrationCount"] = loc.available.Len();
		loc.returnValue["migratedCount"] = 0;
		loc.returnValue["notMigratedCount"] = 0;
		loc.returnValue["versions"] = [];
		for (loc.i in loc.available) {
			loc.tmp = {};
			loc.tmp["version"] = Val(loc.i.version);
			loc.tmp["cfc"] = loc.i.CFCFile;
			loc.tmp["details"] = loc.i.details;
			loc.tmp["migrated"] = loc.i.status == "migrated" ? true : false;
			loc.returnValue["versions"].Append(Duplicate(loc.tmp));
			// see which of the rows in the db have migrations and are actually migrated
			if (ListFind(loc.migrated, Val(loc.i.version))) {
				loc.returnValue["migratedCount"]++;
			} else {
				loc.returnValue["notMigratedCount"]++;
			}
		}

		// make sure that any pending migrations are the last in the array
		loc.returnValue["isOrdered"] = true;
		loop from="#loc.returnValue["migratedCount"]+1#" to="#loc.returnValue["totalMigrationCount"]#" index="loc.i" {
			if (loc.available[loc.i]["status"] == "migrated") {
				loc.returnValue["isOrdered"] = false;
				loc.returnValue["isMigrated"] = false;
				break;
			}
		}
		renderText(text=SerializeJSON(loc.returnValue));
	}

	/**
	 * Returns the current migration version
	 */
	public string function current() {
		renderText(text='{"current":#$$getCurrentMigration()#}');
	}

	/**
	 * Returns the latest available migration version
	 */
	public string function latest() {
		renderText(text='{"latest":#$$getLatestAvailableMigration()#}');
	}

	/**
	 * Returns true if the current migration version is the latest
	 */
	public string function ismigrated() {
		renderText(text='{"ismigrated":#$$getCurrentMigration() == $$getLatestAvailableMigration() ? true : false#}');
	}

	/**
	 * Returns true if the database can be connected to
	 */
	public string function ping() {
		model("DBMigrateVersion").findOne(returnAs="query");
		renderText(text='{"db":"okay"}');
	}

		/*** PRIVATE ***/

		/**
		 * Migrates the database to the latest available version.
		 * Note: Make this public with caution!
		 */
		private string function migrate() {
			renderText(text=$$dbmigrate().migrateTo($$getLatestAvailableMigration()));
		}

		/**
		 * Migrates the database to the latest available version
		 * Note: Make this public with caution!
		 */
		private string function cleanup() {
			// clean up any rows that may have been created but cfcs don't exist.. mainly for use in development --->
			dirty = model("DBMigrateVersion").findAll(where="version NOT IN (#$$getAvailableMigrations().ToList()#)");
			model("DBMigrateVersion").deleteAll(where="version NOT IN (#$$getAvailableMigrations().ToList()#)");
			renderText(text='{"cleaned":"#dirty.recordCount#"}');
		}

		/**
		 * Returns an array of all available migration versions
		 */
		private array function $$getAvailableMigrations() {
			var loc = {};
			loc.returnValue = [];
			for (loc.i in $$dbmigrate().getAvailableMigrations()) {
				loc.returnValue.Append(loc.i.version);
			}
			ArraySort(loc.returnValue, "numeric", "asc");
			return loc.returnValue;
		}

		/**
		 * Returns the latest available migration version number
		 */
		private numeric function $$getLatestAvailableMigration() {
			var loc = {};
			loc.available = [];
			for (loc.i in $$dbmigrate().getAvailableMigrations()) {
				ArrayAppend(loc.available, loc.i.version);
			}
			ArraySort(loc.available, "numeric", "desc");
			return loc.available[1];
		}

		/**
		 * Returns the latest migrated version number
		 */
		private numeric function $$getCurrentMigration() {
			return Val(model("DBMigrateVersion").findLast(order="version").version);
		}

		/**
		 * Returns a pointer to the dbmigrate plugin object
		 */
		private any function $$dbmigrate() {
			return application.wheels.plugins.dbmigrate;
		}

}

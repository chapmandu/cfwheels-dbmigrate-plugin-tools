component extends="Model" output="false" {

	public void function init() {
		table("schemainfo");
		setPrimaryKey("version");
	}

}

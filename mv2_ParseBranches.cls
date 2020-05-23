/****************************************************************************************************************
* 
* @ Name		:  mv2_Parse
* @ Purpose		:  This class is used to generate strongly typed Apex code for parsing a Git Repository JSON
* @ Author		:  Absyz
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===============================================================================================================
*   17-May-2020     |  Absyz					    |  1.0          |  Initial Version

****************************************************************************************************************/

public with sharing class mv2_ParseBranches {

    public String name {get;set;} 
    public Commit_Z commit_Z {get;set;} // in json: commit
    public Boolean protected_Z {get;set;} // in json: protected
    public Protection protection {get;set;} 
    public String protection_url {get;set;} 

    public class Commit_Z {
		public String sha {get;set;} 
		public String url {get;set;} 

		public Commit_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'sha') {
							sha = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Commit_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
    public Mv2_ParseBranches(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'commit') {
                        commit_Z = new Commit_Z(parser);
                    } else if (text == 'protected') {
                        protected_Z = parser.getBooleanValue();
                    } else if (text == 'protection') {
                        protection = new Protection(parser);
                    } else if (text == 'protection_url') {
                        protection_url = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'Mv2_ParseBranches consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
	
	public class Contexts {

		public Contexts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Contexts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Protection {
		public Boolean enabled {get;set;} 
		public Required_status_checks required_status_checks {get;set;} 

		public Protection(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'enabled') {
							enabled = parser.getBooleanValue();
						} else if (text == 'required_status_checks') {
							required_status_checks = new Required_status_checks(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Protection consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Required_status_checks {
		public String enforcement_level {get;set;} 
		public List<Contexts> contexts {get;set;} 

		public Required_status_checks(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'enforcement_level') {
							enforcement_level = parser.getText();
						} else if (text == 'contexts') {
							contexts = arrayOfContexts(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Required_status_checks consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static List<Mv2_ParseBranches> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfMv2_ParseBranches(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Mv2_ParseBranches> arrayOfMv2_ParseBranches(System.JSONParser p) {
        List<Mv2_ParseBranches> res = new List<Mv2_ParseBranches>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Mv2_ParseBranches(p));
        }
        return res;
    }

    private static List<Contexts> arrayOfContexts(System.JSONParser p) {
        List<Contexts> res = new List<Contexts>();
        if (p.getCurrentToken() == null) p.nextToken();
        
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Contexts(p));
        }
        return res;
    }
}
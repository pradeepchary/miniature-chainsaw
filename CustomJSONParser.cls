public class CustomJSONParser{
    public commitClass commit_Z{get;set;}
    public String url{get;set;}
    public String html_url{get;set;}
    public String author{get;set;}
    public String comments_url{get;set;}
    public String committer{get;set;}
    public String node_id{get;set;}
    public list<parentsClass> parents{get;set;}
    public String sha{get;set;}

    public class verificationClass{
        public String payload{get;set;}
        public String signature{get;set;}
        public String reason{get;set;}
        public Boolean verified{get;set;}
    }

    public class treeClass{
        public String url{get;set;}
        public String sha{get;set;}
    }

    public class parentsClass{
        public String sha{get;set;}
        public String html_url{get;set;}
        public String url{get;set;}
    }

    public class committerClass{
        public String date_Z{get;set;}
        public String email_Z{get;set;}
        public String name{get;set;}
    }

    public class commitClass{
        public String comment_count{get;set;}
        public committerClass committer{get;set;}
        public String message{get;set;}
        public authorClass author{get;set;}
        public treeClass tree{get;set;}
        public verificationClass verification{get;set;}
        public String url{get;set;}
    }

    public class authorClass{
        public String date_Z{get;set;}
        public String email_Z{get;set;}
        public String name{get;set;}
    }
}
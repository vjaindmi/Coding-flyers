using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MyApplication.Models
{
    public class ImagProcessing
    {
        public HttpPostedFileBase PostImage { get; set; }
        public string userDefinedTag { get; set; }
        public string apiDefinedTag { get; set; }
    }
}
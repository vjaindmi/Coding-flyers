using Newtonsoft.Json;
using Repository.Concrete;
using Repository.Factories;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using WebApi.Models;

namespace WebApi.Controllers
{
    [System.Web.Http.RoutePrefix("api/v1/app")]
    public class AppApiController : ApiController
    {
        const string subscriptionKey = "f8d649a9c02f4ac9a750bbcfd8902389";
        const string uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze";

        [System.Web.Http.Route("~/api/v1/app/postuserimage")]
        [System.Web.Http.AllowAnonymous]
        public HttpResponseMessage PostUserImage()
        {
            string tags = "No record found";
           Dictionary <string, object> dict = new Dictionary<string, object>();
            try
            {

                var httpRequest = HttpContext.Current.Request;

                foreach (string file in httpRequest.Files)
                {
                    HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.Created);

                    var postedFile = httpRequest.Files[file];
                    if (postedFile != null && postedFile.ContentLength > 0)
                    {

                        int MaxContentLength = 1024 * 1024 * 50; //Size = 1 MB  

                        IList<string> AllowedFileExtensions = new List<string> { ".jpg", ".gif", ".png" };
                        var ext = postedFile.FileName.Substring(postedFile.FileName.LastIndexOf('.'));
                        var extension = ext.ToLower();
                        if (!AllowedFileExtensions.Contains(extension))
                        {

                            var message = string.Format("Please Upload image of type .jpg,.gif,.png.");

                            dict.Add("error", message);
                            return Request.CreateResponse(HttpStatusCode.BadRequest, dict);
                        }
                        else if (postedFile.ContentLength > MaxContentLength)
                        {

                            var message = string.Format("Please Upload a file upto 1 mb.");

                            dict.Add("error", message);
                            return Request.CreateResponse(HttpStatusCode.BadRequest, dict);
                        }
                        else
                        {

                            tags = ProcessRequest(postedFile);
                            //var filePath = HttpContext.Current.Server.MapPath("~/Userimage/" + postedFile.FileName + extension);

                            //postedFile.SaveAs(filePath);


                        }
                    }

                    var message1 = string.Format(tags);
                    return Request.CreateErrorResponse(HttpStatusCode.Created, message1); ;
                }
                var res = string.Format("Please Upload a image.");
                dict.Add("error", res);
                return Request.CreateResponse(HttpStatusCode.NotFound, dict);
            }
            catch (Exception ex)
            {
                var res = string.Format("some Message");
                dict.Add("error", res);
                return Request.CreateResponse(HttpStatusCode.NotFound, dict);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="postedFile"></param>
        /// <returns></returns>
        private string ProcessRequest(HttpPostedFile postedFile)
        {
            var extension = Path.GetExtension(postedFile.FileName);

            var response = MakeAnalysisRequest(postedFile);


            //var parsedResponse = JsonPrettyPrint(response);
            var parsedResponse = FromJSON<ImageUploadObject>(response);
            var tags = parsedResponse.tags.Where(x => x.confidence > 0.90).Select(x => x.name).ToList();
            if(string.IsNullOrEmpty(tags.ToString()))
            {
                return "No Record Found";
            }

            var rootData = JsonConvert.DeserializeObject<ImageUploadObject>(response);
            ImageUploadRequest uploadData = new ImageUploadRequest();
            uploadData.rootObject = rootData;
            uploadData.imageName = DateTime.Now.ToString("yyyyMMddHHmmss") + "." + extension;
            uploadData.tag = tags;



            postedFile.InputStream.Position = 0;
            int fileSizeInBytes = postedFile.ContentLength;
            MemoryStream target = new MemoryStream();
            postedFile.InputStream.CopyTo(target);
            byte[] data = target.ToArray();

            uploadData.imageByte = data;

            string serializedData = JsonConvert.SerializeObject(uploadData);

            IUserData _repository = new UserData();
            var result = _repository.UpdateImageData(uploadData);

            //HttpResponseMessage responseData = PostJsonRequest("http://localhost:6364/api/v1/admin/updateuserimage", serializedData, null);
            //string resultprofile = responseData.Content.ReadAsStringAsync().Result;
            if (result.Succeeded)
            {
                return result.Data;
            }
            else
            {
                return "No Record Found";
            }
           
        }
        private static HttpResponseMessage PostJsonRequest(string route, string contentBody, string token)
        {
            using (HttpClient client = new HttpClient())
            {

                if (!string.IsNullOrWhiteSpace(token))
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                var content = new StringContent(contentBody.ToString(), Encoding.UTF8, "application/json");
                return client.PostAsync(route, content).Result;
            }
        }
        public string MakeAnalysisRequest(HttpPostedFile Image)
        {
            HttpClient client = new HttpClient();

            // Request headers.
            client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", subscriptionKey);

            // Request parameters. A third optional parameter is "details".
            //string requestParameters = "visualFeatures=Categories,Description,Color&language=en";
            string requestParameters = "visualFeatures=Categories,Tags,Description,Color&language=en";

            // Assemble the URI for the REST API Call.
            string uri = uriBase + "?" + requestParameters;

            HttpResponseMessage response;

            // Request body. Posts a locally stored JPEG image.
            MemoryStream stream = new MemoryStream();
            Image.InputStream.CopyTo(stream);


            byte[] byteData = stream.ToArray();

            using (ByteArrayContent content = new ByteArrayContent(byteData))
            {
                // This example uses content type "application/octet-stream".
                // The other content types you can use are "application/json" and "multipart/form-data".
                content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

                // Execute the REST API call.
                response = client.PostAsync(uri, content).Result;

                // Get the JSON response.
                string contentString = response.Content.ReadAsStringAsync().Result;
                return contentString;

                // Display the JSON response.
                //Console.WriteLine("\nResponse:\n");
                //Console.WriteLine(JsonPrettyPrint(contentString));
            }
        }

        private T FromJSON<T>(string input)
        {
            MemoryStream stream = new MemoryStream();

            try
            {
                DataContractJsonSerializer jsSerializer = new DataContractJsonSerializer(typeof(T));
                stream = new MemoryStream(Encoding.UTF8.GetBytes(input));
                T obj = (T)jsSerializer.ReadObject(stream);

                return obj;
            }
            finally
            {
                stream.Close();
                stream.Dispose();
            }
        }
    }
}

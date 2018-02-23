using Repository.Concrete;
using Repository.Factories;
using RestSharp;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApi.Models;

namespace WebApi.Controllers
{
    [RoutePrefix("api/v1/user")]
    public class UserController : ApiController
    {
        const string subscriptionKey = "f8d649a9c02f4ac9a750bbcfd8902389";
        const string uriBase = "https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/8e983fbd-0438-4bd2-9161-8c8cbf81f82e?subscription-key=4e80642610f8481b914a81a0920c8073&verbose=true&timezoneOffset=0";
        /// <summary>
        /// Image API
        /// </summary>
        /// <returns></returns>
        [Route("~/api/v1/user/imagedata")]
        public HttpResponseMessage GetImage()
        {
            IUserData _repository = new UserData();
            var imageList = _repository.GetImageData();
            if (imageList.Succeeded == true)
            {
                return Request.CreateResponse(HttpStatusCode.OK, imageList.Data);
            }
            else
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, "error occured");
            }
            
        }
        
        [Route("~/api/v1/user/imagedata")]
        public HttpResponseMessage GetImage(string requestText)
        {
            var url = string.Format("{0}&q={1}", uriBase, requestText);
            var client = new RestClient(url);
            var request = new RestRequest(Method.GET);
            var response = client.Execute<RootObject>(request);

            if (response != null)
            {
                // var d = JsonConvert.SerializeObject(response);
                // RootObject obj = (RootObject)d;
                IUserData _repository = new UserData();
                var imageList = _repository.ProcessLuisResponse(response.Data);
                if (imageList.Succeeded == true)
                {
                    return Request.CreateResponse(HttpStatusCode.OK, imageList.Data);
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "error occured");
                }
            }
            else
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, "error occured");
            }
        }

        [Route("~/api/v1/user/updateuserimage")]
        [HttpPost]
        public HttpResponseMessage UpdateImageRequest(ImageUploadRequest model)
        {
            IUserData _repository = new UserData();
            var result = _repository.UpdateImageData(model);
            if (result.Succeeded == true)
            {
                return Request.CreateResponse(HttpStatusCode.OK, result.Data);
            }
            else
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest, "error occured");
            }
        }
        [Route("~/api/v1/user/getimage")]
        [HttpGet]
        public HttpResponseMessage getimage(int id)
        {
            IUserData _repository = new UserData();
            var result = _repository.GetImage(id);            
            byte[] imgData = result.Data.Image;
            MemoryStream ms = new MemoryStream(imgData);
            HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.OK);
            response.Content = new StreamContent(ms);
            response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("image/png");
            return response;
        }
    }

}

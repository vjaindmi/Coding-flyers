using Repository.Factories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Repository.DTO;
using WebApi.Models;
using Repository.Entities;
using Newtonsoft.Json;
using System.Net.Http;
using WebApi.Helper;

namespace Repository.Concrete
{
    public class UserData : IUserData
    {
        string imageBaseUrl = "http://learnictify.azurewebsites.net/api/v1/user/getimage";

        public APIResponse<List<DataReponse>> GetImageData()
        {

            using (ApplicationDbContext db = new ApplicationDbContext())
            {
                List<DataReponse> listResponse = new List<DataReponse>();

                //byte[] image = db.ImageData.Where(t => t.Id == 1).FirstOrDefault().Image;

                DataReponse data = new DataReponse();
                data.query = "want to jump on a trampoline";
                data.entities = new List<ReposnseEntity> {
                    new ReposnseEntity(){ entity = "play", Image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQjoRHDfi-RwXDLxSjdM3vPkmzwxbjDJjChnkpclMTOwTfQ3kJs" },
                     new ReposnseEntity(){ entity = "trampoline", Image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiogpKXz6aPtiELlQlU_okRXGrM-yO2bK4X4Cvho6FbVHrs4KHVw" }
                };
                listResponse.Add(data);
                if (listResponse.Any())
                {
                    return new APIResponse<List<DataReponse>>() { Data = listResponse, HttpCode = System.Net.HttpStatusCode.OK, Succeeded = true };
                }
                else
                {
                    return new APIResponse<List<DataReponse>>() { HttpCode = System.Net.HttpStatusCode.NoContent, Succeeded = false };
                }
            }
        }


        public APIResponse<string> UpdateImageData(ImageUploadRequest model)
        {
            StringBuilder sb = new StringBuilder();
            using (ApplicationDbContext db = new ApplicationDbContext())
            {
                try
                {
                    var entity = new ImageDataEntity {
                        ImageName = model.imageName,
                        DataResponse = JsonConvert.SerializeObject(model.rootObject),
                        Image = model.imageByte,
                        DateAdded = DateTime.Now,
                        IsLive = true
                    };                   

                    db.ImageData.Add(entity);
                    db.SaveChanges();
                                       
                    foreach (var q in model.tag)
                    {
                        db.ImageTag.Add(new ImageTagEntity()
                        {
                            ImageId= entity.Id,
                            Name = q,
                            DateAdded = DateTime.Now,
                            IsLive = true
                        });
                        sb.Append(q+", ");
                   }

                    db.SaveChanges();
                    return new APIResponse<string>
                    {
                        Data = sb.ToString(),
                        Succeeded = true
                    };
                }
                catch (Exception ex)
                {
                    return new APIResponse<string>
                    {
                        Data = ex.Message,
                        Succeeded = false
                    };
                }
            }
        }

        public APIResponse<ImageDataEntity> GetImage(int id)
        {
            using (ApplicationDbContext db = new ApplicationDbContext())
            {

                var data = from i in db.ImageData
                           where i.Id == id
                           select i;

                if (data.Any())
                {
                    return new APIResponse<ImageDataEntity>() { Data = data.FirstOrDefault(), HttpCode = System.Net.HttpStatusCode.OK, Succeeded = true };
                }
                else
                {
                    return new APIResponse<ImageDataEntity>() { HttpCode = System.Net.HttpStatusCode.NoContent, Succeeded = false };
                }
            }
        }

        public APIResponse<List<DataReponse>> ProcessLuisResponse(RootObject obj)
        {
            using (ApplicationDbContext db = new ApplicationDbContext())
            {
                var tagsinfo = db.ImageTag;


                List<DataReponse> listResponse = new List<DataReponse>();

                //byte[] image = db.ImageData.Where(t => t.Id == 1).FirstOrDefault().Image;

                DataReponse data = new DataReponse();
                data.query = obj.query;
                List<ReposnseEntity> responseEntity = new List<ReposnseEntity>();
                if (obj.topScoringIntent != null)
                {
                    var rentity = new ReposnseEntity();
                    rentity.entity = obj.topScoringIntent.intent.Split('.')[1];
                    if (tagsinfo != null && tagsinfo.Any())
                    {
                        var selectedEntity = tagsinfo.Where(x => x.Name.Contains(rentity.entity)).FirstOrDefault();
                        if (selectedEntity != null)
                        {
                            rentity.Image = string.Format("{0}?id={1}", imageBaseUrl, selectedEntity.ImageId);
                        }
                    }
                    responseEntity.Add(rentity);
                }

                if (obj.entities != null)
                {
                    foreach (var ob in obj.entities)
                    {
                        var rentity = new ReposnseEntity();
                        rentity.entity = ob.entity;
                        if (tagsinfo != null && tagsinfo.Any())
                        {
                            var selectedEntity = tagsinfo.Where(x => x.Name.Contains(rentity.entity)).FirstOrDefault();
                            if (selectedEntity != null)
                            {
                                rentity.Image = string.Format("{0}?id={1}", imageBaseUrl, selectedEntity.ImageId);
                            }
                        }
                        responseEntity.Add(rentity);

                    }

                }

                data.entities = responseEntity;

                listResponse.Add(data);
                if (listResponse.Any())
                {
                    return new APIResponse<List<DataReponse>>() { Data = listResponse, HttpCode = System.Net.HttpStatusCode.OK, Succeeded = true };
                }
                else
                {
                    return new APIResponse<List<DataReponse>>() { HttpCode = System.Net.HttpStatusCode.NoContent, Succeeded = false };
                }
            }
        }
    }
}


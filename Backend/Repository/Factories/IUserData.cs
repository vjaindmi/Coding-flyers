using Repository.DTO;
using Repository.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebApi.Models;

namespace Repository.Factories
{
    public interface IUserData
    {
        APIResponse<List<DataReponse>> GetImageData();
        APIResponse<string> UpdateImageData(ImageUploadRequest model);
        APIResponse<List<DataReponse>> ProcessLuisResponse(RootObject obj);
        APIResponse<ImageDataEntity> GetImage(int id);
    }
}

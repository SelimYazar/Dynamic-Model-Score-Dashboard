using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExcelDataReader;
using System.Text;
using Newtonsoft.Json;
using System.Linq;

// ChartJSCore kütüphanesi gerekli namespace'leri ekleyelim
using ChartJSCore.Models;

namespace _152120191023_Selim_Can_Yazar_WebBasedTechnologies_Hw2
{
    public partial class Default : System.Web.UI.Page
    {
        // Repeater kontrolü
        protected Repeater rptModels;
        // HiddenField kontrolü 
        protected HiddenField hfGeneralChartJson;

        // Bu property, Repeater item sayısını istemci tarafında kullanmak için
        protected int ModelCount { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // ExcelDataReader'ın doğru çalışması için (kod sayfada 1 kez register edilmeli)
                Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

                // bar-data.xlsx projenizin kök dizininde ise:
                string filePath = Server.MapPath("~/bar-data.xlsx");

                // Excel verilerini oku
                List<ModelData> models = ReadExcelData(filePath);

                // Score değerine göre büyükten küçüğe sıralama
                models = models.OrderByDescending(m => m.Score).ToList();

                // Her model için "ChartJson" alanını oluşturuyoruz
                foreach (var model in models)
                {
                    // Yatay bar grafik (her modelin skorunu yatay bar olarak göstereceğiz)
                    var chartConfig = CreateHorizontalBarChart(model.Name, model.Score);
                    model.ChartJson = chartConfig; // JSON çıktısını saklıyoruz
                }

                // Repeater kontrolüne veriyi bağla
                rptModels.DataSource = models;
                rptModels.DataBind();

                // ModelCount property, istemci tarafındaki for döngüsü için
                ModelCount = models.Count;

                // Genel Chart: Tüm modellerin skorlarını tek grafikte göstermek
                var generalChartConfig = CreateGeneralChart(models);
                // HiddenField'a JSON çıktısını atıyoruz, .aspx tarafında <%= hfGeneralChartJson.ClientID %> üzerinden erişilecek
                hfGeneralChartJson.Value = generalChartConfig;
            }
        }

        // ExcelDataReader ile Excel dosyasından veri okuma metodu
        private List<ModelData> ReadExcelData(string filePath)
        {
            var models = new List<ModelData>();

            using (var stream = File.Open(filePath, FileMode.Open, FileAccess.Read))
            {
                using (var reader = ExcelReaderFactory.CreateReader(stream))
                {
                    var result = reader.AsDataSet();
                    var dt = result.Tables[0];

                    // Başlık satırını atlayarak 1. satırdan başlayalım (0. satırda kolon isimleri olduğunu varsayıyoruz)
                    for (int i = 1; i < dt.Rows.Count; i++)
                    {
                        string name = dt.Rows[i][0].ToString();
                        double score = 0;
                        double.TryParse(dt.Rows[i][1].ToString(), out score);

                        // Yeni: Description sütununu okuyup ModelData'ya ekliyoruz
                        string description = "";
                        if (dt.Columns.Count > 2) // 3. sütun (index 2) var mı kontrolü
                        {
                            description = dt.Rows[i][2].ToString();
                        }

                        models.Add(new ModelData
                        {
                            Name = name,
                            Score = score,
                            Description = description
                        });
                    }
                }
            }
            return models;
        }

        // Tek model için yatay bar grafik oluşturup JSON döndüren metot
        private string CreateHorizontalBarChart(string modelName, double score)
        {
            // Chart.js yapısına uygun olarak manuel JSON oluşturalım
            var chartData = new
            {
                type = "bar",
                data = new
                {
                    labels = new[] { modelName },
                    datasets = new[]
                    {
                        new
                        {
                            label = "Score",
                            data = new[] { score },
                            backgroundColor = new[] { "rgba(255, 99, 132, 0.6)" },
                            borderColor = new[] { "rgba(255, 99, 132, 1)" },
                            borderWidth = 1
                        }
                    }
                },
                options = new
                {
                    indexAxis = "y", // Yatay bar grafiği için
                    scales = new
                    {
                        x = new
                        {
                            beginAtZero = true
                        }
                    }
                }
            };

            return JsonConvert.SerializeObject(chartData);
        }

        // Genel (tüm modeller) sütun grafiği
        private string CreateGeneralChart(List<ModelData> models)
        {
            var labels = new List<string>();
            var scores = new List<double>();
            foreach (var m in models)
            {
                labels.Add(m.Name);
                scores.Add(m.Score);
            }

            var chartData = new
            {
                type = "bar",
                data = new
                {
                    labels = labels.ToArray(),
                    datasets = new[]
                    {
                        new
                        {
                            label = "Model Scores",
                            data = scores.ToArray(),
                            backgroundColor = new[] { "rgba(54, 162, 235, 0.6)" },
                            borderColor = new[] { "rgba(54, 162, 235, 1)" },
                            borderWidth = 1
                        }
                    }
                },
                options = new
                {
                    scales = new
                    {
                        y = new
                        {
                            beginAtZero = true
                        }
                    }
                }
            };

            return JsonConvert.SerializeObject(chartData);
        }

        /// <summary>
        /// Accordion header ve body genişliği için, skorun ondalıklı kısmı 0.40 ve üzeriyse Math.Ceiling,
        /// altında ise Math.Floor uygular. Sadece width değeri için kullanılır.
        /// </summary>
        protected string GetRoundedWidth(double score)
        {
            double fractional = score - Math.Floor(score);
            if (fractional >= 0.40)
            {
                // .40 ve üzeri => üst tam sayıya yuvarla
                return Math.Ceiling(score).ToString();
            }
            else
            {
                // .40 altı => alt tam sayıya yuvarla
                return Math.Floor(score).ToString();
            }
        }
    }

    // Excel verilerindeki model bilgilerini temsil eden sınıf
    public class ModelData
    {
        public string Name { get; set; }
        public double Score { get; set; }
        public string ChartJson { get; set; }

        // Yeni: Description sütunu için property
        public string Description { get; set; }
    }
}




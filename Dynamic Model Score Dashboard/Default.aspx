<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs"
    Inherits="_152120191023_Selim_Can_Yazar_WebBasedTechnologies_Hw2.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <meta charset="utf-8" />
  <title>HW2 - Using ChartJsCore</title>

  <!-- jQuery ve jQuery UI accordion için -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <link rel="stylesheet"
        href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css" />
  <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>

  <!-- Chart.js (ChartJsCore, Chart.js'i kullanır) -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <!-- Bootstrap CSS -->
  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
    rel="stylesheet"
    integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3"
    crossorigin="anonymous"
  />
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />

  <style>
      /* Genel Model Skorları Bölümü */
      .general-chart-wrapper {
          height: 100vh;
          display: flex;
          flex-direction: column;
          box-sizing: border-box;
      }
      .general-chart-title {
          height:10vh;
          margin: 0;
          padding: 0;
          line-height: 100%;
      }
      .general-chart-container {
          height:90vh;
          position: relative;
          padding: 0 15px;
      }
      .general-chart-container canvas {
          width: 100% !important;
          height: 100% !important;
      }

      /* Accordion Bölümü */
      #accordion {
          height: 100vh;
          margin: auto 0px !important;
      }
      
      /* jQuery UI Accordion Header (varsayılan stilleri geçersiz kılma) */
      /* Accordion kapalı iken (normal durum) */
      .ui-accordion .ui-accordion-header,
      .ui-accordion .ui-accordion-header.ui-state-default {
          background: linear-gradient(to top right, #FF8C00, #FFFF00);
          color: white !important;
          border: none !important;
          margin-bottom:2px;
          padding: 10px;
          cursor: pointer;
      }

      /* Accordion açıkken (active durum) */
      .ui-accordion .ui-accordion-header.ui-state-active {
          background-color: #FFA500 !important;
          background-image: none !important;
          color: white !important;
      }

      /* Hover durumunda */
      .ui-accordion .ui-accordion-header.ui-state-hover {
          background-color: #FFA500 !important;
          background-image: none !important;
          color: white !important;
      }
      
      /* Accordion Body (yükseklik %50vh olarak ayarlandı) */
      .ui-accordion-content {
          background-color: #FFE5B4 !important;
          padding: 10px;
          max-height: 50vh;
          overflow: auto;
      }

      /* Description paneli (grafiğin sağ tarafında gösterilecek) */
      .description-panel {
          background-color: #FFA500; /* Hover rengiyle uyumlu koyu renk */
          color: white;             /* Yazı rengi beyaz */
          font-size: 12px;           /* 8 px font boyutu */
          padding: 5px;
      }
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <!-- Genel Model Skorları Bölümü -->
    <div class="container">
      <div class="general-chart-wrapper">
        <h2 class="general-chart-title text-center">Genel Model Skorları</h2>
        <div class="general-chart-container">
          <canvas id="generalChart"></canvas>
          <asp:HiddenField ID="hfGeneralChartJson" runat="server" />
        </div>
      </div>
    </div>

    <!-- Accordion Bölümü -->
    <div class="container mt-5">
      <div id="accordion">
        <asp:Repeater ID="rptModels" runat="server">
          <ItemTemplate>
            <!-- Header genişliği: yuvarlanmış skor yüzdesi -->
            <h3 id="accordionHeader_<%# Container.ItemIndex %>" 
                title="Score: <%# Eval("Score") %>" 
                style="width: <%# GetRoundedWidth((double)Eval("Score")) + "%" %>;">
              <i class="fas fa-chart-bar"></i> <%# Eval("Name") %>: <%# Eval("Score") %>
            </h3>

            <!-- Body: Grafik sol, açıklama sağ (Bootstrap grid kullanılarak) -->
            <div class="chart-container" style="width: <%# GetRoundedWidth((double)Eval("Score")) + "%" %>;">
              <div class="row">
                <div class="col-11">
                  <canvas id="chart_<%# Container.ItemIndex %>" width="400" height="150"></canvas>
                  <input type="hidden" id="hfChartJson_<%# Container.ItemIndex %>" value='<%# Eval("ChartJson") %>' />
                </div>
                <div class="col-1 description-panel">
                  <%# Eval("Description") %>
                </div>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>
  </form>

  <script>
      // Rastgele renk üreten fonksiyon
      function getRandomColor() {
          var r = Math.floor(Math.random() * 256);
          var g = Math.floor(Math.random() * 256);
          var b = Math.floor(Math.random() * 256);
          return "rgb(" + r + ", " + g + ", " + b + ")";
      }

      // Chart.js konfigürasyonundaki datasetlere rastgele renk atamak, animasyon ve hover etkileşimini güncellemek için yardımcı fonksiyon
      function updateChartConfig(config) {
          if (!config.options) {
              config.options = {};
          }
          config.options.animation = { duration: 1000 };
          // Hover alanını daraltmaya yönelik ayar
          config.options.interaction = { mode: 'nearest', intersect: true };

          if (config.data && config.data.datasets) {
              config.data.datasets.forEach(function (dataset) {
                  dataset.backgroundColor = dataset.data.map(function() { return getRandomColor(); });
                  dataset.hoverBackgroundColor = dataset.data.map(function() { return getRandomColor(); });
              });
          }
          return config;
      }

      $(function () {
          // Accordion'ı, başlangıçta hiçbir panelin açık olmadığı şekilde başlatıyoruz.
          $("#accordion").accordion({
              collapsible: true,
              active: false,
              heightStyle: "content"
          });

          // Genel grafikteki bar tıklanma işlemi: tıklanan barın index'ine göre accordion açılıyor ve o header'a scroll yapılıyor.
          var generalChartJson = document.getElementById("<%= hfGeneralChartJson.ClientID %>").value;
          if (generalChartJson) {
              var generalCtx = document.getElementById("generalChart").getContext("2d");
              var config = JSON.parse(generalChartJson);
              config = updateChartConfig(config);
              var generalChart = new Chart(generalCtx, config);

              generalCtx.canvas.onclick = function(event) {
                  var activePoints = generalChart.getElementsAtEventForMode(event, 'point', { intersect: true }, false);
                  if (activePoints.length > 0) {
                      var index = activePoints[0].index;
                      $("#accordion").accordion("option", "active", index);
                      $('html, body').animate({
                          scrollTop: $("#accordionHeader_" + index).offset().top
                      }, 500);
                  }
              };
          }

          // Her modelin grafiğini accordion içindeki ilgili canvas'a çizdiriyoruz.
          var itemCount = <%= ModelCount %>;
          for (var i = 0; i < itemCount; i++) {
              var hfId = "hfChartJson_" + i;
              var canvasId = "chart_" + i;
              var jsonStr = document.getElementById(hfId).value;
              if (jsonStr) {
                  var ctx = document.getElementById(canvasId).getContext("2d");
                  var chartConfig = JSON.parse(jsonStr);
                  chartConfig = updateChartConfig(chartConfig);
                  new Chart(ctx, chartConfig);
              }
          }
      });
  </script>
</body>
</html>

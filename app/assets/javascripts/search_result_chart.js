/***
@param[String] id : id of the canvas chart element.
@param[Object] year_wise_data : {year : [total_up, total down]} 
@called_from : application.js#render_search_result_new
***/
var draw_chart = function(id,search_result){
    var year_wise_data = search_result.year_wise_data;
    var ctx = document.getElementById(id).getContext('2d');
    var labels = Object.keys(year_wise_data);
    
    var up_data = [];
    var up_data_background_color = [];
    var up_data_border_color = [];

    var down_data = [];
    var down_data_background_color = [];
    var down_data_border_color = [];

    var equal_data = [];
    var equal_data_background_color = [];
    var equal_data_border_color = [];

    var data = [];
    var data_background_color = [];
    var data_border_color = [];


    _.each(Object.values(year_wise_data),function(k){
        if(k[0] > k[1]){
            data.push(k[0] - k[1]);
            data_background_color.push('rgba(0,128,128,0.8)');
            data_border_color.push('rgba(0,128,128,1');

            up_data.push(k[0]);
            down_data.push(k[1]);
            equal_data.push(0);
            up_data_background_color.push('rgba(0,128,128,0.8)');
            up_data_border_color.push('rgba(0,128,128,1');
            down_data_background_color.push('rgba(255,0,0,0.1)');
            down_data_border_color.push('rgba(255,0,0,0.1');
        }
        else if(k[0] == k[1]){
            data.push(k[0]);
            data_background_color.push('rgba(128,128,128,0.2)');
            data_border_color.push('rgba(128,128,128,1');

            up_data.push(0);
            down_data.push(0);
            equal_data.push(k[0]);
            up_data_background_color.push('rgba(0,128,128,0.8)');
            up_data_border_color.push('rgba(0,128,128,1');
            down_data_background_color.push('rgba(255,0,0,0.1)');
            down_data_border_color.push('rgba(255,0,0,0.1');
        }
        else{
            data.push(k[1] - k[0]);
            data_background_color.push('rgba(255,0,0,0.8)');
            data_border_color.push('rgba(255,0,0,1');

            up_data.push(k[0]);
            down_data.push(k[1]);
            equal_data.push(0);
            up_data_background_color.push('rgba(0,128,128,0.1)');
            up_data_border_color.push('rgba(0,128,128,0.1');
            down_data_background_color.push('rgba(255,0,0,0.8)');
            down_data_border_color.push('rgba(255,0,0,1');
        }
        
        

        
        equal_data_background_color.push('rgba(128,128,128,0.2)');
        equal_data_border_color.push('rgba(128,128,128,1');
    }); 

    var title = search_result.target +  " / " + search_result.complex_string;
    
    /***
    {
        label: '# Reacted Positively',
        data: up_data,
        backgroundColor: up_data_background_color,
        borderColor: up_data_border_color,
        borderWidth: 1
    },
    {
        label: '# Reacted Negatively',
        data: down_data,
        backgroundColor: down_data_background_color,
        borderColor: down_data_border_color,
        borderWidth: 1
    },
    {
        label: '# Mixed Reaction',
        data: equal_data,
        backgroundColor: equal_data_background_color,
        borderColor: equal_data_border_color,
        borderWidth: 1
    }
    ****/

    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: "Result",
                    data: data,
                    backgroundColor: data_background_color,
                    borderColor: data_border_color,
                    borderWidth : 1
                }   
            ]
        },
        options: {
            maintainAspectRatio: false,
            title: {
                display: true,
                text: title
            },
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true
                    }
                }]
            }
        }
    });
    

    // so we have only one chart.
}
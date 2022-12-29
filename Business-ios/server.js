'use strict';

const express = require("express");
let app = express();
const axios = require("axios");
const port = process.env.PORT || 8080;

app.use(express.static('dist'));
app.get('/', function (req, res) {
    res.sendFile( __dirname + "/" + "dist" + "/" + "index.html");
})
app.get('/search', function (req, res) {
    res.sendFile( __dirname + "/" + "dist" + "/" + "index.html");
})
app.get('/bookings', function (req, res) {
    res.sendFile( __dirname + "/" + "dist" + "/" + "index.html");
})

let yelp_response;
let geo_response;
let lat_val;
let lng_val;
let detail_response;
let review_response;
let autocomplete_response;

app.get('/yelp', async function (req, res) {
  console.log("yelp")

  let API_KEY = "6JKmZljPu9qhq7BFYQFF0zhKD_X4r2cdy4aNkfNZFf7um9-abI6vG6k4xwTCqQ9yFnu-myifFqljBTMOyQ5D7Abh3MKa5o_fzQjNj2qFewG7W7Dn0WjKj4AUanU3Y3Yx";
  let HEADERS = {"Authorization": `Bearer ${API_KEY}`};
  let yelp_url = 'https://api.yelp.com/v3/businesses/search';

  let key = req.query.term;
  let loc = req.query.location;
  let cat = req.query.category;
  let dis = req.query.distance;
  let lat = req.query.lat;
  let lng = req.query.lng;

  if (cat == "Default") {
    cat = "all";
  }
  let rad = Math.round(dis * 1609.3);

  // geocode api
  if (loc != "") {
    console.log("geocode")
    let geo_url = 'https://maps.googleapis.com/maps/api/geocode/json?address=';
    let apiKey = 'AIzaSyD1O4tSSJAdhpbmBLkJh7Zhh9aOBGtSBqw';
    let address = loc;
    let final_url = geo_url + address + "&key=" + apiKey;
  
    axios.get(final_url)
    .then(function (response) {
        geo_response = response.data;
        console.log(geo_response);
        lat_val = geo_response['results'][0]['geometry']['location']['lat'];
        lng_val = geo_response['results'][0]['geometry']['location']['lng'];
        console.log(lat_val);
        console.log(lng_val);
        // res.json(response.data);
  
        // get yelp api response
        let yelp_param = {'term': key,
                          'categories': cat,
                          'radius': rad,
                          'latitude': lat_val,
                          'longitude': lng_val,
                          'limit': 10}
      
        console.log(yelp_param);
      
        axios({
            method: 'get',
            url: yelp_url,
            params: yelp_param,
            headers: HEADERS,
        })
        .then(function (response) {
            console.log("hi",response.data);
            yelp_response = response.data;
            // console.log(yelp_response.businesses[0].name);
            res.json(response.data);
        })
        .catch(function (err) {
            console.log(err);
        })
    })
  
    .catch(function (err) {
        console.log(err);
    })
  }

  // if using ipinfo
  else {
    console.log(lat);
    console.log(lng);
    let yelp_param = {'term': key,
                      'categories': cat,
                      'radius': rad,
                      'latitude': lat,
                      'longitude': lng,
                      'limit': 10}
  
    console.log(yelp_param);
  
    axios({
        method: 'get',
        url: yelp_url,
        params: yelp_param,
        headers: HEADERS,
    })
    .then(function (response) {
        yelp_response = response.data;
        // console.log(yelp_response.businesses[0].name);
        console.log(response.data);
        res.json(response.data);
    })
    .catch(function (err) {
        console.log(err);
    })
  }
 
})


// yelp_detail
app.get('/detail', async function (req, res) {
  console.log('detail');
  let yelp_id = req.query.id;
  // let yelp_id = 'a_uYoJZXXU6qchol8caoGA';
  let API_KEY = "6JKmZljPu9qhq7BFYQFF0zhKD_X4r2cdy4aNkfNZFf7um9-abI6vG6k4xwTCqQ9yFnu-myifFqljBTMOyQ5D7Abh3MKa5o_fzQjNj2qFewG7W7Dn0WjKj4AUanU3Y3Yx";
  let HEADERS = {"Authorization": `Bearer ${API_KEY}`};
  let yelp_url = `https://api.yelp.com/v3/businesses/${yelp_id}`;
  // console.log(req.query.id);
  // console.log(yelp_url);

  axios({
      method: 'get',
      url: yelp_url,
      headers: HEADERS,
  })
  .then(function (response) {
      // console.log(response);
      detail_response = response.data;
      console.log(detail_response.name);
      res.json(response.data);
  })
  .catch(function (err) {
      console.log(err);
  })
})

app.get('/review', async function (req, res) {
    console.log('review');
    let yelp_id = req.query.id;
    let API_KEY = "6JKmZljPu9qhq7BFYQFF0zhKD_X4r2cdy4aNkfNZFf7um9-abI6vG6k4xwTCqQ9yFnu-myifFqljBTMOyQ5D7Abh3MKa5o_fzQjNj2qFewG7W7Dn0WjKj4AUanU3Y3Yx";
    let HEADERS = {"Authorization": `Bearer ${API_KEY}`};
    let yelp_review_url = `https://api.yelp.com/v3/businesses/${yelp_id}/reviews`;
  
    axios({
        method: 'get',
        url: yelp_review_url,
        headers: HEADERS,
    })
    .then(function (response) {
        // console.log(response);
        review_response = response.data;
        console.log(review_response.reviews[0].rating);
        res.json(response.data);
    })
    .catch(function (err) {
        console.log(err);
    })
  })

app.get('/autocomplete', function (req, res) {
    console.log('autocomplete');
    let text = req.query.text;
    let API_KEY = "6JKmZljPu9qhq7BFYQFF0zhKD_X4r2cdy4aNkfNZFf7um9-abI6vG6k4xwTCqQ9yFnu-myifFqljBTMOyQ5D7Abh3MKa5o_fzQjNj2qFewG7W7Dn0WjKj4AUanU3Y3Yx";
    let HEADERS = {"Authorization": `Bearer ${API_KEY}`};
    let yelp_autocomplete_url = `https://api.yelp.com/v3/autocomplete?text=${text}`;
    axios({
        method: 'get',
        url: yelp_autocomplete_url,
        headers: HEADERS,
    })
    .then(function (response) {
        console.log(autocomplete_response);
        autocomplete_response = response.data;
        res.send(autocomplete_response);
    })
    .catch(function (err) {
        console.log(err);
    })
})


// app.listen(port, () => console.log(`Listening on port ${port}`));
const PORT = process.env.PORT || 8080;
app.listen(PORT,()=>{
    console.log('Web Connected !')
})
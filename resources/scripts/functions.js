
function getURLParameter(name) {
        return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
        }

function data_xql(rootName, root) {
//    if (getURLParameter("root") === null) {
//            loadCollection = "/db/data";
//    } else {
        loadCollection = root;
//    }
    if (getURLParameter("node") === null) {
        activeCollection = loadCollection;
    } else {
        activeCollection = loadCollection+"/"+getURLParameter("node");
    }

        //$("#editButton").hide();
        //$("#executeButton").hide();
        //$("#downloadButton").hide();
        //$("#printButton").hide();

        $('#collection-tree').dynatree({
            persist: false,
            rootVisible: true,
            initAjax: {url: "json.xql?root="+loadCollection+"&rootName="+rootName },
            clickFolderMode: 1,
            onPostInit: function(isReloading, isError) {
                var dbNode = this.getNodeByKey(activeCollection);
                dbNode.activate();
                dbNode.expand(true);
            },
            onActivate: function(node) {
                if(!node.data.isFolder) {
                    $("#documentpath").text(node.data.key+'/'+node.data.title);
                    $('#document').text("Loading..");
                    $.ajax({
                        dataType: 'text',
                        url: "./../../modules/load.xql?path="+node.data.key+'/'+node.data.title,
                        success: function( xml ){
                            //$('#document').append((new XMLSerializer()).serializeToString(xml));
                            $('#document').text($.trim(xml));
                            $('#document').attr("class","prettyprint");
                            if ( $('#document').text().length < 100000) {
                                 prettyPrint();
                            }
                        },
                        error: function(e) {
                            alert("error: "+e);
                        }
                    });
                    if (node.data.title.match(".xql$") || node.data.title.match(".xquery$")) {
                            //$("#downloadButton").hide();
                            $("#executeButton").attr("href","../../rest"+node.data.key+'/'+node.data.title);
                            //$("#executeButton").show();
                        } else {
                            //$("#executeButton").hide();
                            $("#downloadButton > a").attr("href","./../../modules/download.xql?file="+node.data.key+"/"+node.data.title);
                            $("#downloadButton > a").attr("download",node.data.title);
                            $("#downloadButton").attr("class","enabled");
                        }
                    $("#editButton").attr("class","enabled");
                    $("#editButton > a").attr("data-template","templates:load-source");
                    $("#editButton > a").attr("href","./../../../eXide/index.html?open="+node.data.key+'/'+node.data.title);
                    if (node.data.title.match(".xml$") && node.data.key.match("/db/data/Drucktexte")) {
                            // $("#printButton").show();
                             $("#printInputFile").attr("value",node.data.key+'/'+node.data.title);
                        } else {
                            //$("#printButton").hide();
                        }
                    // Update Modals
                    $("#newResourceFormTargetCollection").val(node.data.key.substring(root.length+1));
                    $("#newCollectionFormTargetCollection").val(node.data.key.substring(root.length+1));
                    $("#removeResourceFormCollection").val(node.data.key.substring(root.length+1));
                    $("#removeResourceFormResource").val(node.data.title);
                    $("#removeResourceFormResourcePath").text('"'+node.data.key.substring(root.length+1)+"/"+node.data.title+'"');
                } else {
                    $("#editButton").attr("class","disabled")//.hide();
                    $("#executeButton").attr("class","disabled")
                    $("#downloadButton").attr("class","disabled")
                    $("#printButton").attr("class","disabled")
                    $("#documentpath").text(node.data.key);
                   $('#document').text("");
                   $("#downloadButton").removeAttr("href");
                   $("#downloadButton").removeAttr("download");
                   $("#editButton").removeAttr("href");
                   $("#editButton").removeAttr("data-template");
                   // Update Modals
                   $("#newResourceFormTargetCollection").val(node.data.key.substring(root.length+1));
                   $("#newCollectionFormTargetCollection").val(node.data.key.substring(root.length+1));
                   $("#removeResourceFormCollection").val(node.data.key.substring(root.length+1));
                   $("#removeResourceFormResource").val("");
                   $("#removeResourceFormResourcePath").text('"'+node.data.key.substring(root.length+1)+'"');
                }
            }
       });
}

//myvar = getURLParameter('myvar');

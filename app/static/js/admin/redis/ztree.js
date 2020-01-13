$(document).ready(function() {
	var url = '/api/serverTree?groupId=' + groupId + '&serverName=' + serverName;
	initZTree(url);
	$(".refresh_btn").on("click", function() {
		var url = '/api/refresh';
		refreshZTree(url);
	});

	$(".addServer_btn").on("click", function() {
		var url = basePath + '/redis/addServer';
		var formParam = $("#addServerModalForm").formSerialize();
		$.ajax({
			type: "post",
			url : url,
			dataType: "json",
			data: formParam,
			success : function(data) {
				window.location.href = basePath + '/redis/stringList/' + serverName + '/' + dbIndex;
			}
		})
	})
});

function initZTree(url) {
	$.ajax({
		type: "get",
		url: url,
		dataType: "json",
		data: {},
		success : function(data) {
			var setting = {
					callback: {
						onClick : function(event, treeId, treeNode) {
							var zTree = $.fn.zTree.getZTreeObj("treeDemo");
							if (treeNode.isParent) {
								//if(!treeNode.open)
								zTree.expandNode(treeNode);
								refreshPage(treeNode.attach.groupId, treeNode.attach.serverName, treeNode.attach.dbIndex, treeNode.attach.keyPrefixs);
								return true;
							} else {
								refreshPage(treeNode.attach.groupId, treeNode.attach.serverName, treeNode.attach.dbIndex, treeNode.attach.keyPrefixs);
								return true;
							} 
						}
				}
			};
			var zNodes = data;
			var treeObj = $.fn.zTree.init($("#treeDemo"), setting, zNodes);
            // var node = treeObj.getNodeByTId("treeDemo_18");  //选中第一个节点
			//var node = treeObj.getNodeByParam("name", serverHost);
            //treeObj.expandNode(node, true, false, true);  //打开节点 ，第一个参数表示哪个节点，第二个参数表示展开还是关闭，第三个参数表示 是否打开全部子孙节点
			//treeObj.selectNode(node)
		}
	});
}

function refreshZTree(url) {
	$.ajax({
		type: "get",
		url: url,
		dataType: "json",
		data: {},
		success : function(data) {
			if(data.returncode == "200") {
				refreshPage(groupId, serverName, dbIndex, []);
			} else {
				modelAlert(data);
			}
		}
	});
}

function refreshPage(groupId, serverName, dbIndex, arr) {
	if(dbIndex==-1) {
		return ;
	}
	var url = '/redis/group/' + groupId +'/' + serverName + '/' + dbIndex;
	for(var i=0;i<arr.length;i++){
		if(i==0) {
			url = url + '?keyPrefixs=' + arr[0];
			continue;
		}
		url = url + '&keyPrefixs=' + arr[i];
	}
	window.location.href = url;
}

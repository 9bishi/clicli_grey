import 'package:clicli_grey/utils/dio_utils.dart';

const host = 'https://www.clicli.cc';

getPost(
  String sort,
  String tag,
  int page,
  int pageSize, {
  status = 'public',
  uid = '',
}) {
  final res = NetUtils.get(
      '$host/posts?status=$status&sort=$sort&tag=$tag&uid=$uid&page=$page&pageSize=$pageSize');
  return res;
}

getPostDetail<T>(int pid) {
  return NetUtils.get('$host/post/$pid');
}

getPlayUrl(String? url) {
  return NetUtils.get('$host/play?url=$url');
}

getSearch(String? key) {
  return NetUtils.get('$host/search/posts?key=$key');
}

getRank() {
  return NetUtils.get('$host/rank');
}

getPV(int? id) {
  return NetUtils.get('$host/pv/$id');
}

getComments(int? pid, pageSize){
  return NetUtils.get('$host/comments?pid=$pid&page=1&pageSize=$pageSize');
}

login(data) {
  return NetUtils.post('$host/user/login', data);
}

addComment(data){
  return NetUtils.post('$host/comment/add', data);
}

checkAppUpdateApi() {
  return NetUtils.get(
      'https://cdn.jsdelivr.net/npm/@clicli/app@3.0.6/web/output-metadata.json');
}

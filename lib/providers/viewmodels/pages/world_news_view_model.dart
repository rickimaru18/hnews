import 'package:hnews/env.dart';
import 'package:hnews/providers/repository.dart';
import 'package:hnews/providers/viewmodels/pages/news_view_model.dart';

class WorldNewsViewModel extends NewsViewModel {
  WorldNewsViewModel(Repository repository) : super(repository, Env.worldNews);
}

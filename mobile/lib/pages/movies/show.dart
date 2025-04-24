import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmbal_movies_app/controllers/auth_controller.dart';
import 'package:kmbal_movies_app/controllers/movies_controller.dart';
import 'package:kmbal_movies_app/models/movie.dart';
import 'package:kmbal_movies_app/models/review.dart';
import 'package:kmbal_movies_app/tokens.dart';

class ShowMoviePage extends StatefulWidget {
  const ShowMoviePage({super.key});

  @override
  State<StatefulWidget> createState() => MoviesPageState();
}

class MoviesPageState extends State<ShowMoviePage> {
  final MoviesController _moviesController = Get.find();
  final AuthController _authController = Get.find();

  late final Future<Movie> _movie = _moviesController.fetchMovie(
    Get.parameters['id']!,
  );

  final RxList<Review> _reviews = <Review>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    try {
      final reviews = await _moviesController.fetchMovieReviews(
        Get.parameters['id']!,
      );
      _reviews.assignAll(reviews);
    } catch (e) {
      // Handle error
    }
  }

  bool hasUserReviewed(int userId) {
    return _reviews.any((review) => review.userId == userId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.chevron_left,
          ),
        ),
      ),
      persistentFooterButtons: [
        Obx(() {
          final userId = _authController.userId;
          final userHasReviewed = userId == null ? false : hasUserReviewed(userId);

          return Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((state) {
                      if (state.contains(WidgetState.disabled)) {
                        return ColorTokens.lightBlue900;
                      }
                      return ColorTokens.darkBlue100;
                    }),
                  ),
                  onPressed: userHasReviewed
                      ? null
                      : () async {
                          final result = await Get.toNamed("/movies/show/review", parameters: {
                            "id": Get.parameters['id']!,
                          });
                          if (result == true) {
                            // Show success message
                            //
                            // Handle success
                            Get.snackbar(
                              "Success",
                              "Review submitted successfully.",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                            _fetchReviews();
                          }
                        },
                  child: Text(
                    userHasReviewed ? "Already Reviewed" : "Review",
                  ),
                ),
              ),
            ],
          );
        }),
      ],
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      child: FutureBuilder(
                        future: _movie,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error loading movie.");
                          }

                          if (snapshot.hasData) {
                            return MovieUi(snapshot.requireData);
                          }

                          return Text("Loading movie...");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Reviews",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 8),
                  AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        if (_reviews.isEmpty) {
                          return Text("No reviews yet.");
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: _reviews
                              .map<Widget>((review) => ReviewItem(review))
                              .toList(),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieUi extends StatelessWidget {
  final Movie _movie;

  const MovieUi(this._movie, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: ColorTokens.lightBlue100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _movie.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 4),
          Text(
            _movie.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review _review;

  const ReviewItem(this._review, {super.key});

  String _rating() {
    return "★" * _review.rating + "☆" * (5 - _review.rating);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: ColorTokens.lightBlue100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _rating(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 4),
          Text(
            _review.review,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

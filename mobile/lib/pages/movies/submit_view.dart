import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kmbal_movies_app/tokens.dart';

import '../../controllers/movies_controller.dart';
import '../../models/api_response.dart';

class SubmitViewPage extends StatefulWidget {
  const SubmitViewPage({super.key});

  @override
  State<SubmitViewPage> createState() => _SubmitViewPageState();
}

class _SubmitViewPageState extends State<SubmitViewPage> {
  final MoviesController moviesController = Get.find();

  bool _isLoading = false;

  set isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  onSubmit(
    double rating,
    String description,
  ) async {
    if (_isLoading) {
      return;
    }
    // Handle the submission of the review
    isLoading = true;
    final id = Get.parameters['id']!;
    moviesController.submitReview(id, rating, description).then((_) {
      isLoading = false;
      // Return to the previous screen
      Get.back<bool>(result: true);
    }).catchError((e) {
      isLoading = false;

      // Handle error
      Get.snackbar(
        "Ops, something went wrong",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
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
      body: Column(
        children: [
          if (_isLoading)
            const Center(
              child: LinearProgressIndicator(),
            ),
          Expanded(
            child: _ReviewForm(
              onSubmit: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm({super.key, required this.onSubmit});

  final Function(double rating, String description) onSubmit;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12),
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text("Share Your Experience",
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              )),
                          const SizedBox(height: 8),
                          Text("Please take a moment to rate and review",
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.blueGrey.shade300,
                              )),
                          const SizedBox(height: 16),
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text("Description",
                                textAlign: TextAlign.start,
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            minLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your review here',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a review.';
                              }
                              if (value.length < 3) {
                                return 'Review must be at least 3 characters.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(vertical: 16),
                          ),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((state) {
                            if (state.contains(WidgetState.disabled)) {
                              return ColorTokens.lightBlue900;
                            }
                            return ColorTokens.darkBlue100;
                          }),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Handle form submission
                            widget.onSubmit(
                                _rating, _descriptionController.text);
                          }
                        },
                        child: Text(
                          "Submit",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

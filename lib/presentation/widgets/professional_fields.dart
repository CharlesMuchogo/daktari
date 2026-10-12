import 'package:daktari/presentation/bloc/categories/categories_bloc.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfessionalDetails {
  final licenseNumber = TextEditingController();
  final hospital = TextEditingController();
  final description = TextEditingController();
  String? categoryId;

  ProfessionalDetails({
    String licenseNumber = '',
    String hospital = '',
    String description = '',
    this.categoryId,
  }) {
    this.licenseNumber.text = licenseNumber;
    this.hospital.text = hospital;
    this.description.text = description;
  }

  bool get isComplete =>
      categoryId != null &&
      licenseNumber.text.trim().isNotEmpty &&
      hospital.text.trim().isNotEmpty;

  void dispose() {
    licenseNumber.dispose();
    hospital.dispose();
    description.dispose();
  }
}

class ProfessionalFields extends StatelessWidget {
  const ProfessionalFields({
    super.key,
    required this.details,
    required this.onCategoryChanged,
    this.showDescription = false,
  });

  final ProfessionalDetails details;
  final ValueChanged<String?> onCategoryChanged;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: details.licenseNumber,
          label: "Licence number",
          icon: Icons.badge_outlined,
        ),
        gap,
        AppTextField(
          controller: details.hospital,
          label: "Hospital or clinic address",
          icon: Icons.location_on_outlined,
        ),
        gap,
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state.categories.isEmpty) {
              return state.status.isFailure
                  ? ErrorState(
                      message: state.message,
                      onRetry: () => context.read<CategoriesBloc>().add(
                        const CategoriesRequested(),
                      ),
                    )
                  : const Loading();
            }
            final known = state.categories.any(
              (c) => c.id == details.categoryId,
            );
            return DropdownButtonFormField<String>(
              initialValue: known ? details.categoryId : null,
              decoration: const InputDecoration(
                labelText: "Specialty",
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: [
                for (final category in state.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: onCategoryChanged,
            );
          },
        ),
        if (showDescription) ...[
          gap,
          AppTextField(
            controller: details.description,
            label: "About you",
            icon: Icons.description_outlined,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ],
    );
  }
}

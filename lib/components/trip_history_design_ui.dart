import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portu_go_driver/models/trips_history_model.dart';

import '../constants.dart';

class TripHistoryDesignUI extends StatefulWidget {
  TripsHistoryModel? tripsHistoryModel;

  TripHistoryDesignUI({super.key, this.tripsHistoryModel});

  @override
  State<TripHistoryDesignUI> createState() => _TripHistoryDesignUIState();
}

class _TripHistoryDesignUIState extends State<TripHistoryDesignUI> {
  DateTime? untreatedDateAndTime;
  String? treatedDateAndTime;

  String treatDateAndTimeText(String dateAndTime) {
    untreatedDateAndTime = DateTime.parse(dateAndTime);
    treatedDateAndTime = '${DateFormat.MMMd().format(untreatedDateAndTime!)}, ${DateFormat.y().format(untreatedDateAndTime!)}  -  ${DateFormat.jm().format(untreatedDateAndTime!)}';
    return treatedDateAndTime!;
  }
  @override
  Widget build(BuildContext context) {
    String passengerName = widget.tripsHistoryModel!.passengerName!.toString();
    String tripPrice = widget.tripsHistoryModel!.tripPrice!.toString();
    String originAddress = widget.tripsHistoryModel!.originAddress!.toString();
    String destinationAddress = widget.tripsHistoryModel!.destinationAddress!.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray3,
        borderRadius: BorderRadius.circular(AppSpaceValues.space3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpaceValues.space2),
        child: Column(
          children: [
            // Trip time:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.gray9,
                  size: AppSpaceValues.space3,
                ),

                const SizedBox(width: AppSpaceValues.space2),

                Text(
                  treatDateAndTimeText(widget.tripsHistoryModel!.time!),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: AppFontSizes.ml,
                    color: AppColors.gray9,
                    fontWeight: AppFontWeights.medium,
                    height: AppLineHeights.ml
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpaceValues.space2),
            const Divider(height: 1, thickness: 1, color: AppColors.gray5),
            const SizedBox(height: AppSpaceValues.space3),

            // Passenger name:
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.indigo7,
                  size: AppSpaceValues.space3,
                ),

                const SizedBox(width: AppSpaceValues.space2),

                SizedBox(
                  width: 300,
                  child: Text(
                    'Passageiro: $passengerName',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: AppFontSizes.ml,
                      color: AppColors.gray7,
                      fontWeight: AppFontWeights.regular,
                      height: AppLineHeights.ml
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpaceValues.space3),

            // Trip price:
            Row(
              children: [
                const Icon(
                  Icons.euro,
                  color: AppColors.indigo7,
                  size: AppSpaceValues.space3,
                ),

                const SizedBox(width: AppSpaceValues.space2),

                Text(
                  'Preço: ' + tripPrice,
                  style: const TextStyle(
                    fontSize: AppFontSizes.ml,
                    color: AppColors.gray7,
                    fontWeight: AppFontWeights.regular,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpaceValues.space3),

            // Origin address:
            Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.indigo7,
                  size: AppSpaceValues.space3,
                ),

                const SizedBox(width: AppSpaceValues.space2),

                SizedBox(
                  width: 300,
                  child: Text(
                    'Origem: ' + originAddress,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: AppFontSizes.ml,
                      color: AppColors.gray7,
                      fontWeight: AppFontWeights.regular,
                      height: AppLineHeights.ml
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpaceValues.space3),

            // Destination address:
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.indigo7,
                  size: AppSpaceValues.space3,
                ),

                const SizedBox(width: AppSpaceValues.space2),

                SizedBox(
                  width: 300,
                  child: Text(
                    'Destino: ' + destinationAddress,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: AppFontSizes.ml,
                      color: AppColors.gray7,
                      fontWeight: AppFontWeights.regular,
                      height: AppLineHeights.ml
                    ),
                  ),
                ),
                // Trip time:
              ],
            ),
          ],
        ),
      ),
    );
  }
}

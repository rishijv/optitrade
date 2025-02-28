import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class ApiService {
  // Fetches daily data for a given ticker using yahoo_finance_data_reader
  Future<YahooFinanceResponse> fetchDailyData(String ticker) async {
    try {
      YahooFinanceDailyReader reader = YahooFinanceDailyReader();
      // getDailyDTOs returns a YahooFinanceResponse that contains candle data
      YahooFinanceResponse response = await reader.getDailyDTOs(ticker);
      return response;
    } catch (e) {
      throw Exception('Failed to load data for $ticker: $e');
    }
  }
}

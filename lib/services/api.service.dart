import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/services/http.service.dart';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/model/response.model.dart';
import 'dart:developer';

class ApiService {
  static Future<ResponseModel> getUserDetails() async {
    try {
      final response =
          await get("${ApiConstants.apiUrl}/v1/common/user/details");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getNumberOfCretedHunt() async {
    try {
      final response =
          await get("${ApiConstants.apiUrl}/v1/common/user/usage-details");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> myPlayedGames(String type) async {
    try {
      final response = await get(
          "${ApiConstants.apiUrl}/v1/app/game-play/my-played-games?gameType=$type");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> myHuntGames(String type) async {
    try {
      final response = await get(
          "${ApiConstants.apiUrl}/v1/app/game/end-games?gameType=$type");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> upcommingGames(String type) async {
    try {
      final response = await get(
          "${ApiConstants.apiUrl}/v1/app/game/upcomming-games?gameType=$type");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getLeaderboardData(int gameId) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/common/game/leader-board", {
        "game_id": gameId,
      });
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> initiateGameCreate() async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step0", {});
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> updateGameTitle(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step1", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> updateGameCheck(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step2", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> addGameItem(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step3", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> addGameItemLibrary(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/insert-hunt-library-items", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> addGameItemManually(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/insert-items-manually", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> updateGameItem(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/updateGameItem", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> setGameTime(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step4", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> uploadGamePicture(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step5", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> updateGameRules(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/create-game-step6", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getGameTeam(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/game-team", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> submitHunt(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/submit-hunt", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> acceptPlayerItem(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/accept-player-item", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> rejectPlayerItem(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/reject-player-item", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getGameStatus(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/game-status", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> endGame(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/ended-game", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> activateGame(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/actived-game", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> joinGame(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game-play/join-game", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> changeGameStatus(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game-play/change-status", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> fetchGameItems(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game-play/my-game-items", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  // /v1/app/game/update-items-seq

  static Future<ResponseModel> reOrderingItemList(dynamic data) async {
    try {
      log(data.toString());

      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game/update-items-seq", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        log(response.statusCode.toString());
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

// new
  static Future<ResponseModel> reOrderingItemListchalleng(dynamic data) async {
    try {
      log(data.toString());

      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/challenge/update-items-seq", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        log(response.statusCode.toString());
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> fetchNewGameItemsList(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game-play/my-game-items-v2", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> gameDetails(dynamic gameId,
      [String? isjoined]) async {
    try {
      final response = await get(
          "${ApiConstants.apiUrl}/v1/app/game/game-details?qry=$gameId&isjoined=$isjoined");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> mainLeaderBoard() async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game-play/main-leaderboard", {});
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> uploadGameItem(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/app/game-play/upload-item", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<String> uploadFile(dynamic filepath) async {
    final response = await upload("${ApiConstants.uploadUrl}/upload", filepath);
    return response;
  }

  static Future<ResponseModel> getItemGroupList(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/item/group-list", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getItemGroupDetails(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/item/fetchGroupDetails", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> updateUserDetails(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/user/update-profile", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        // throw Exception('Failed to load data');
        print('${response.statusCode}');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getCountryList(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/country-state/country-list", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      // print(response.body);
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getStateList(dynamic data) async {
    try {
      final response = await post(
          "${ApiConstants.apiUrl}/v1/country-state/state-list-by-country",
          data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      // print({">>>>>state datad datad dayad>>>>>>>respodata", response.body});

      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> paymentIntent(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/payment/create-payment-intent", data);
    // print(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> paymentIntentFree(
      dynamic data, BuildContext context) async {
    log("this is the data >>>>>>>${data.toString()}");
    final response =
        await post("${ApiConstants.apiUrl}/v1/payment/buyFreeItemGroup", data);
    // print(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      // throw Exception('Failed to load data');
      log("api call unsuccess ${response.statusCode}");

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen(userName: '')));
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> paymentResponse(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/payment/payment-response", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteGame(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game/delete-game", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateInTime(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game/updateGameType", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> fetchUserPurchaseHistory(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/item/fetchUserPurchaseHistory", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteItem(int data) async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/app/game/delete-game-item/$data");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> purchaseItemList(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/item/purchase-item-list", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> leaveGame(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game-play/leave-hunt", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getGameList(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/game/fetchGameList", data);
      print(response);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> getGameVideoList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game-play/getGamePlayedVideoList", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getEndGameDetails(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game/end-game-details", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> relaunchGame(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game/relaunchGame", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> createChallenge(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/challenge/create", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateChallenge(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/challenge/update", data);

    log("response of the updated challenge >>${response.statusCode}");
    log("response of the updated challenge >>${response.body}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getChallengeList(dynamic data) async {
    try {
      final response =
          await post("${ApiConstants.apiUrl}/v1/app/challenge/fetchList", data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to load data');
      }
      return ResponseModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      return ResponseModel(
          success: false, status: '400', message: '', response: null);
    }
  }

  static Future<ResponseModel> insertChallengeItems(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/insertChallengeItems", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> insertChallengeItemsManually(
      dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/insertItemsManually", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> uploadItemImage(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/uploadItemImage", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateChallengeItem(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/updateChallengeItem", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> markAsComplete(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/markAsComplete", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> joinChallenge(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/joinChallengeUsingQR", data);
    // final response = await post(
    //     "${ApiConstants.apiUrl}/v1/app/challenge/joinChallenge", data);

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 400 &&
        response.statusCode != 500) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getChallengeDetails(dynamic qry) async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/app/challenge/details?qry=$qry");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    // print({">>>>>>>>>>>>mmmmmmmmmmmmm", response.body});
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getCarouselScrollInfo() async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/carousel/getScrollInfo");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    // print({">>>>>>>>>>>>mmmmmmmmmmmmm", response.body});
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteChallenge(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/challenge/delete", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }

    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> changePassword(dynamic data) async {
    final response =
        await post("${ApiConstants.baseUrl}/password-change", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }

    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> sentOtp(dynamic data) async {
    final response = await post("${ApiConstants.baseUrl}/sent-otp", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }

    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> createTeam(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/app/game-play/create-team", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateTeamName(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game-play/update-team-name", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getMyTeamList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game-play/my-team-list", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> forgotPassword(dynamic data) async {
    final response =
        await post("${ApiConstants.baseUrl}/forget-password", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> logIn(dynamic data) async {
    final response = await post("${ApiConstants.baseUrl}/login", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> signUp(dynamic data) async {
    final response = await post("${ApiConstants.baseUrl}/registration", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> relaunChChallenge(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/relaunchChallenge", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> verifyOtp(dynamic data) async {
    final response = await post("${ApiConstants.baseUrl}/verify-otp", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> resetPassword(dynamic data) async {
    final response = await post("${ApiConstants.baseUrl}/reset-password", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> removeChallengeItem(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/removeChallengeItem", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getMyItems(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/item/get-my-items", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteMyItems(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/deleteMyItems", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deletegameJoiner(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game/delete-player-game", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getChallengeVideoList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/getChallengeVideoList", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateTeamMemberList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game-play/update-team-participants",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteTeamMemberList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game-play/delete-team-participants",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> updateIntimeGame(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/game/update-game-intime", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> globalSearchItem(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/item/globalSearchItems", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getCarouselData(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/carousel/getCarouselData", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getAllActiveSubscriptions() async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/app/getAllActiveSubscriptions");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getUserSubscriptions(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/admin/subscription/getUserSubscriptions",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> subcriptionIntent(dynamic data) async {
    final response = await post(
        // create-payment-intent-subscription
        "${ApiConstants.apiUrl}/v1/payment/create-recurring-payment-subscription",
        data);
    print(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> subcriptionResponse(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/payment/payment-response-subscription",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> addChallengeItem(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/item/create-items-manually", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getAllCategories() async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/admin/category/getAllCategories");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getAllSubCatagory(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/admin/category/fetchSubCategoriesByCategoryId",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> parchesedHistoryList(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/admin/subscription/fetchUserSubscriptionHistory",
        data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> deleteAccount(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/user/delete-profile", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> allCouponList() async {
    final response =
        await get("${ApiConstants.apiUrl}/v1/discount/fetchAvailableDiscounts");
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> addCoupon(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/discount/checkDiscount", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> cancelsubcription(dynamic data) async {
    final response =
        await post("${ApiConstants.apiUrl}/v1/payment/cancelAutoRenewal", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ResponseModel> getUniqueChallengeId(dynamic data) async {
    final response = await post(
        "${ApiConstants.apiUrl}/v1/app/challenge/getUniqueChallengeId", data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load data');
    }
    return ResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}

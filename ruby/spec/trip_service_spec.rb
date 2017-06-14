require 'spec_helper'

describe TripService do
  describe 'in dynamically typed code' do
    let(:no_user) { nil }

    before do
      @trip_service = TripService.new
    end

    it 'throws an error when there is no user logged in' do
      stub_logged_user_with(no_user)

      expect do
        @trip_service.get_trip_by_user(nil)
      end.to raise_error UserNotLoggedInException
    end

    it 'returns an empty trip list when users are not friends' do
      logged_user = double(:logged_user)
      stub_logged_user_with(logged_user)
      
      a_friend = double(:a_friend)      
      user = UserBuilder.a_user
        .friend_with([a_friend])
        .build

      trips = @trip_service.get_trip_by_user(user)
      
      expect(trips).to eq([])
    end

    it 'returns the list of trips with users are friends' do
      logged_user = UserBuilder.a_user.build
      stub_logged_user_with(logged_user)
      expected_trips = [double(:trip)]
      stub_tripdao_with(expected_trips)
      user = UserBuilder.a_user
        .friend_with([logged_user])
        .build

      trips = @trip_service.get_trip_by_user(user)

      expect(trips).to eq(expected_trips)
    end

    def stub_tripdao_with(trips)
      allow(TripDAO).to receive(:find_trips_by_user)
        .and_return(trips)
    end

    def stub_logged_user_with(user)
      user_session = double(:user_session, get_logged_user: user)
      allow(UserSession).to receive(:get_instance)
        .and_return(user_session)
    end

    class UserBuilder
      def self.a_user
        new
      end

      def initialize
        @friends = []
      end

      def friend_with(friends)
        friends.each do |friend|
          @friends << friend
        end
        self
      end

      def build
        user = User.new
        @friends.each do |friend|
          user.add_friend(friend)
        end
        user
      end
    end
  end

  describe 'in statically typed code' do
    @@logged_user = nil

    it 'throws an error when there is no user logged in' do
      trip_service = TestableTripService.new
      with_not_logged_user
      

      expect do
        trip_service.get_trip_by_user(nil)
      end.to raise_error UserNotLoggedInException
    end

    def with_not_logged_user
      @@logged_user = nil
    end

    class TestableTripService < TripService
      def get_logged_user
        @@logged_user
      end
    end
  end

  
end

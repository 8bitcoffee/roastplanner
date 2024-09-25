import { combineReducers, Reducer } from 'redux';

// Define the shape of the action
interface Action {
  type: string;
}

// Define the type for the login message state
type LoginMessageState = string;

// Reducer for handling login messages
const loginMessage: Reducer<LoginMessageState, Action> = (state = '', action): LoginMessageState => {
  switch (action.type) {
    case 'CLEAR_LOGIN_ERROR':
      return '';
    case 'LOGIN_INPUT_ERROR':
      return 'Enter your username and password!';
    case 'LOGIN_FAILED':
      return "Oops! The username and password didn't match. Try again!";
    case 'LOGIN_FAILED_NO_CODE':
      return 'Oops! Something went wrong! Is the server running?';
    default:
      return state;
  }
};

// Define the type for the registration message state
type RegistrationMessageState = string;

// Reducer for handling registration messages
const registrationMessage: Reducer<RegistrationMessageState, Action> = (state = '', action): RegistrationMessageState => {
  switch (action.type) {
    case 'CLEAR_REGISTRATION_ERROR':
      return '';
    case 'REGISTRATION_INPUT_ERROR':
      return 'Choose a username and password!';
    case 'REGISTRATION_FAILED':
      return "Oops! That didn't work. The username might already be taken. Try again!";
    default:
      return state;
  }
};

// Combine the reducers into one object with keys loginMessage and registrationMessage
// These will be on the Redux state at:
// state.errors.loginMessage and state.errors.registrationMessage
const errorsReducer = combineReducers({
  loginMessage,
  registrationMessage,
});

export default errorsReducer;
Template.displayIcon.userIconUrl = ->
  # TODO: We should specify default URL to the image of an avatar which is generated from name initials
  "https://secure.gravatar.com/avatar/#{ Meteor.person()?.gravatarHash }?s=24"

Template._loginButtonsLoggedInDropdownActions.personSlug = ->
  Meteor.person()?.slug

Template._loginButtonsLoggedInSingleLogoutButton.displayName = ->
  Meteor.person()?.displayName()

Template._loginButtonsLoggedInDropdown.displayName = Template._loginButtonsLoggedInSingleLogoutButton.displayName

changingPasswordInResetPassword = false

# To close sign in buttons dialog box when clicking, focusing or pressing a key somewhere outside
$(document).on 'click focus keypress', (e) ->
  # originalEvent is defined only for native events, but we are triggering
  # click manually as well, so originalEvent is not always defined
  unless e.originalEvent?.accountsDialogBoxEvent
    Accounts._loginButtonsSession.closeDropdown()
    Accounts._loginButtonsSession.set 'resetPasswordToken', null
    changingPasswordInResetPassword = false
  return # Make sure CoffeeScript does not return anything

# But if clicked inside, we mark the event so that dialog box is not closed
Template._loginButtons.events
  'click #login-buttons, focus #login-buttons, keypress #login-buttons': (e, template) ->
    e.accountsDialogBoxEvent = true
    return # Make sure CoffeeScript does not return anything

$(document).on 'keyup', (e) ->
  if e.keyCode is 27 # Escape key
    Accounts._loginButtonsSession.closeDropdown()
    Accounts._loginButtonsSession.set 'resetPasswordToken', null
    changingPasswordInResetPassword = false
  return # Make sure CoffeeScript does not return anything

# Don't allow dropping files while password reset is in progress
Template._resetPasswordDialog.events
  'dragover': (e, template) ->
    e.preventDefault()
    return # Make sure CoffeeScript does not return anything

  'dragleave': (e, template) ->
    e.preventDefault()
    return # Make sure CoffeeScript does not return anything

  'drop .hide-background': (e, template) ->
    e.stopPropagation()
    e.preventDefault()
    return # Make sure CoffeeScript does not return anything

  'click .accounts-centered-dialog, focus .accounts-centered-dialog, keypress .accounts-centered-dialog': (e, template) ->
    e.accountsDialogBoxEvent = true
    return # Make sure CoffeeScript does not return anything

  'click #login-buttons-reset-password-button': (e, template) ->
    changingPasswordInResetPassword = true
    return # Make sure CoffeeScript does not return anything

  'keypress #reset-password-new-password': (e, template) ->
    changingPasswordInResetPassword = true if event.keyCode is 13 # Enter key
    return # Make sure CoffeeScript does not return anything

  'click #login-buttons-cancel-reset-password': (e, template) ->
    changingPasswordInResetPassword = false
    return # Make sure CoffeeScript does not return anything

Template._resetPasswordDialog.rendered = ->
  Meteor.defer =>
    $(@findAll '#reset-password-new-password').focus()

# When password is reset or reset is canceled, we change the location to the index page
lastResetPasswordToken = null
Deps.autorun ->
  resetPasswordToken = Accounts._loginButtonsSession.get 'resetPasswordToken'
  if resetPasswordToken is null and lastResetPasswordToken
    Notify.success "Password reset." if changingPasswordInResetPassword
    Meteor.Router.toNew Meteor.Router.indexPath()
  lastResetPasswordToken = resetPasswordToken
  changingPasswordInResetPassword = false

Handlebars.registerHelper 'currentUserId', (options) ->
  Meteor.userId()

lastPersonId = Meteor.personId()

Deps.autorun ->
  return if Meteor.loggingIn()

  personId = Meteor.personId()
  if personId isnt lastPersonId
    if personId
      Notify.success "Signed in."
    else
      Notify.success "Signed out."
    lastPersonId = personId

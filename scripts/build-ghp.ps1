git fetch origin gh-pages:gh-pages
flutter pub global run peanut:peanut --extra-args "--base-href /quicksend/"
git push origin gh-pages

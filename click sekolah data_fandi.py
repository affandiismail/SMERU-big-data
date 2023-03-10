from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time
import winsound

# Set up the browser driver and turn off images
chrome_options = webdriver.ChromeOptions()
prefs = {"profile.managed_default_content_settings.images": 2}
chrome_options.add_experimental_option("prefs", prefs)
driver = webdriver.Chrome(chrome_options=chrome_options)

# Load the page
url = 'https://sekolah.data.kemdikbud.go.id/'
driver.get(url)

# click the first page
first = driver.find_element(By.CSS_SELECTOR, 'button[type="submit"]')
first.click()

# Find the '>>' button and click it repeatedly until the maximum page is reached
while True:
    try:
        button = WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.CSS_SELECTOR, 'a[aria-label="Next"]')))
        button.click()
        time.sleep(1.5)
    except TimeoutException:
        # Display a message to indicate that the wait timed out
        print("Timed out while waiting for button, retrying...")
    except:
        # Handle any other exceptions that may occur
        break

# Print the maximum page
max_page = driver.find_element(By.CSS_SELECTOR, 'ul.pagination>li:last-child>a')
onclick_value = max_page.get_attribute('onclick')
page_number = int(onclick_value.split('(')[-1].split(')')[0])
print('Maximum number:', page_number)
# frequency is set to 500Hz
freq = 300
# duration is set to 100 milliseconds            
dur = 200
winsound.Beep(freq, dur)

winsound.Beep(freq, dur)
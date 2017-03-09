#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import abc

import six


@six.add_metaclass(abc.ABCMeta)
class BaseTemplate(object):

    def __init__(self, parameters):
        super(BaseTemplate, self).__init__()
        self._parameters = parameters

    @property
    def parameters(self):
        return self._parameters

    @abc.abstractproperty
    def schema(self):
        """Defines a Schema that the input parameters shall comply to

        :returns: A schema declaring the input parameters this template
                  should be provided along with their respective constraints
        """
        raise NotImplementedError()
